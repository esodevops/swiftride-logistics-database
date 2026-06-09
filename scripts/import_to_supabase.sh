#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
DATASET_DIR="${PROJECT_DIR}/dataset"
DB_URL=${SUPABASE_DB_URL:-}
ENV_FILE="${PROJECT_DIR}/.env.supabase"
INIT_SCHEMA=false
RESET_DATA=false

usage() {
    cat <<EOF
Usage:
    SUPABASE_DB_URL="postgresql://postgres:<DB_PASSWORD>@db.<PROJECT-REF>.supabase.co:5432/postgres?sslmode=require" scripts/import_to_supabase.sh [--init-schema] [--reset]

    OR create ${ENV_FILE} with:
    SUPABASE_DB_URL="postgresql://postgres:<DB_PASSWORD>@db.<PROJECT-REF>.supabase.co:5432/postgres?sslmode=require"
    Then run:
    scripts/import_to_supabase.sh [--init-schema] [--reset]

Options:
  --init-schema  Run ddl/Swiftride_logistics_ddl_solutions_db.sql before importing CSV data.
  --reset        Truncate existing project tables before import.

Notes:
  - If your password has special characters (for example #), URL-encode them (example: # becomes %23).
  - CSV files are loaded from ${DATASET_DIR}.
  - Import order is foreign-key safe.
  - Constraint updates from dml/Swift_logistics_dml.sql are applied before import.
  - Serial sequences are repaired after import so future inserts work correctly.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --init-schema)
            INIT_SCHEMA=true
            ;;
        --reset)
            RESET_DATA=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ -z "$DB_URL" && -f "$ENV_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$ENV_FILE"
    DB_URL=${SUPABASE_DB_URL:-}
fi

if [[ -z "$DB_URL" ]]; then
    echo "SUPABASE_DB_URL is not set (and ${ENV_FILE} was not found or missing SUPABASE_DB_URL)." >&2
    echo "Tip: URL-encode special password characters like # as %23." >&2
    usage
    exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
    echo "psql is required but was not found in PATH." >&2
    exit 1
fi

run_psql() {
    psql "$DB_URL" -v ON_ERROR_STOP=1 "$@"
}

import_csv() {
    local table_name=$1
    local columns=$2
    local file_name=$3
    local file_path="${DATASET_DIR}/${file_name}"

    if [[ ! -f "$file_path" ]]; then
        echo "Missing CSV file: ${file_path}" >&2
        exit 1
    fi

    echo "Importing dataset/${file_name} -> ${table_name}"
    run_psql -c "\\copy ${table_name}(${columns}) FROM '${file_path}' WITH (FORMAT csv, HEADER true)"
}

if [[ "$INIT_SCHEMA" == true ]]; then
    echo "Running schema setup"
    run_psql -f "${PROJECT_DIR}/ddl/Swiftride_logistics_ddl_solutions_db.sql"
fi

echo "Applying constraint updates"
run_psql -f "${PROJECT_DIR}/dml/Swift_logistics_dml.sql"

if [[ "$RESET_DATA" == true ]]; then
    echo "Resetting existing project data"
    run_psql <<'SQL'
TRUNCATE TABLE
    operations.deliveries,
    finance.payments,
    operations.orders,
    warehouse.inventory,
    operations.customers,
    fleet.drivers,
    fleet.vehicles,
    warehouse.warehouses
RESTART IDENTITY CASCADE;
SQL
fi

import_csv operations.customers "customer_id, full_name, email, phone_number, city" customers.csv
import_csv fleet.drivers "driver_id, driver_name, license_number, phone_number, status" drivers.csv
import_csv fleet.vehicles "vehicle_id, vehicle_type, plate_number, capacity" vehicles.csv
import_csv warehouse.warehouses "warehouse_id, warehouse_name, location" warehouses.csv
import_csv operations.orders "order_id, customer_id, order_date, delivery_address, total_amount" orders.csv
import_csv operations.deliveries "delivery_id, order_id, driver_id, vehicle_id, delivery_status" deliveries.csv
import_csv warehouse.inventory "inventory_id, warehouse_id, product_name, quantity" inventory.csv
import_csv finance.payments "payment_id, order_id, payment_method, payment_status" payments.csv

echo "Repairing sequences"
run_psql <<'SQL'
SELECT setval('operations.customers_customer_id_seq', COALESCE((SELECT MAX(customer_id) FROM operations.customers), 1), true);
SELECT setval('fleet.drivers_driver_id_seq', COALESCE((SELECT MAX(driver_id) FROM fleet.drivers), 1), true);
SELECT setval('fleet.vehicles_vehicle_id_seq', COALESCE((SELECT MAX(vehicle_id) FROM fleet.vehicles), 1), true);
SELECT setval('warehouse.warehouses_warehouse_id_seq', COALESCE((SELECT MAX(warehouse_id) FROM warehouse.warehouses), 1), true);
SELECT setval('operations.orders_order_id_seq', COALESCE((SELECT MAX(order_id) FROM operations.orders), 1), true);
SELECT setval('operations.deliveries_delivery_id_seq', COALESCE((SELECT MAX(delivery_id) FROM operations.deliveries), 1), true);
SELECT setval('warehouse.inventory_inventory_id_seq', COALESCE((SELECT MAX(inventory_id) FROM warehouse.inventory), 1), true);
SELECT setval('finance.payments_payment_id_seq', COALESCE((SELECT MAX(payment_id) FROM finance.payments), 1), true);
SQL

echo "Validating row counts"
run_psql <<'SQL'
SELECT 'operations.customers' AS table_name, COUNT(*) AS row_count FROM operations.customers
UNION ALL
SELECT 'fleet.drivers', COUNT(*) FROM fleet.drivers
UNION ALL
SELECT 'fleet.vehicles', COUNT(*) FROM fleet.vehicles
UNION ALL
SELECT 'warehouse.warehouses', COUNT(*) FROM warehouse.warehouses
UNION ALL
SELECT 'operations.orders', COUNT(*) FROM operations.orders
UNION ALL
SELECT 'operations.deliveries', COUNT(*) FROM operations.deliveries
UNION ALL
SELECT 'warehouse.inventory', COUNT(*) FROM warehouse.inventory
UNION ALL
SELECT 'finance.payments', COUNT(*) FROM finance.payments
ORDER BY table_name;
SQL

echo "Supabase import completed successfully"
