#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
ENV_FILE="${PROJECT_DIR}/.env.supabase"
REPORT_DIR="${PROJECT_DIR}/reports"
REPORT_FILE="${REPORT_DIR}/swiftride_management_report.md"
TMP_REPORT_FILE="${REPORT_FILE}.tmp"
DB_URL=${SUPABASE_DB_URL:-}

usage() {
    cat <<EOF
Usage:
  scripts/management_report.sh

Creates a management-ready Markdown report at:
  ${REPORT_FILE}

Set SUPABASE_DB_URL in your shell or create:
  ${ENV_FILE}
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ -z "$DB_URL" && -f "$ENV_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$ENV_FILE"
    DB_URL=${SUPABASE_DB_URL:-}
fi

if [[ -z "$DB_URL" ]]; then
    echo "SUPABASE_DB_URL is not set." >&2
    usage
    exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
    echo "psql is required but was not found in PATH." >&2
    exit 1
fi

mkdir -p "$REPORT_DIR"
trap 'rm -f "$TMP_REPORT_FILE"' EXIT

run_query() {
    local sql=$1

    psql "$DB_URL" \
        -v ON_ERROR_STOP=1 \
        -X \
        -q \
        -A \
        -P footer=off \
        -F $'\t' \
        -c "$sql"
}

append_markdown_table() {
    local title=$1
    local insight=$2
    local sql=$3
    local tmp_file

    tmp_file=$(mktemp)
    run_query "$sql" > "$tmp_file"

    {
        printf '\n## %s\n\n' "$title"
        printf '%s\n\n' "$insight"

        awk -F '\t' '
            NR == 1 {
                printf "|"
                for (i = 1; i <= NF; i++) {
                    gsub(/\|/, "\\|", $i)
                    printf " %s |", $i
                }
                printf "\n|"
                for (i = 1; i <= NF; i++) {
                    printf " --- |"
                }
                printf "\n"
                next
            }
            {
                printf "|"
                for (i = 1; i <= NF; i++) {
                    gsub(/\|/, "\\|", $i)
                    printf " %s |", $i
                }
                printf "\n"
            }
        ' "$tmp_file"
        printf '\n'
    } >> "$TMP_REPORT_FILE"

    rm -f "$tmp_file"
}

{
    printf '# SwiftRide Logistics Management Report\n\n'
    printf 'Generated from the SwiftRide PostgreSQL database using the operational SQL queries.\n\n'
    printf 'Report generated: %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf '## Executive Summary\n\n'
    printf 'This report summarizes customer activity, delivery operations, revenue, payment status, inventory levels, and cross-schema operational visibility for SwiftRide Logistics.\n'
} > "$TMP_REPORT_FILE"

append_markdown_table \
    "Database Coverage" \
    "This section confirms the number of records available across the core business areas." \
    "SELECT 'Customers' AS metric, COUNT(*) AS total_records FROM operations.customers
     UNION ALL SELECT 'Drivers', COUNT(*) FROM fleet.drivers
     UNION ALL SELECT 'Vehicles', COUNT(*) FROM fleet.vehicles
     UNION ALL SELECT 'Warehouses', COUNT(*) FROM warehouse.warehouses
     UNION ALL SELECT 'Orders', COUNT(*) FROM operations.orders
     UNION ALL SELECT 'Deliveries', COUNT(*) FROM operations.deliveries
     UNION ALL SELECT 'Inventory Items', COUNT(*) FROM warehouse.inventory
     UNION ALL SELECT 'Payments', COUNT(*) FROM finance.payments
     ORDER BY metric;"

append_markdown_table \
    "Top 10 High-Value Customers" \
    "These customers generate the highest order value and are strong candidates for loyalty rewards, premium support, or targeted retention campaigns." \
    "SELECT
         c.full_name AS customer,
         COUNT(o.order_id) AS total_orders,
         TO_CHAR(SUM(o.total_amount), 'FM999,999,999,990.00') AS total_spent
     FROM operations.customers c
     JOIN operations.orders o ON c.customer_id = o.customer_id
     GROUP BY c.full_name
     ORDER BY SUM(o.total_amount) DESC
     LIMIT 10;"

append_markdown_table \
    "Driver Delivery Workload" \
    "This view helps management understand driver workload distribution and identify top-performing or heavily assigned drivers." \
    "SELECT
         d.driver_name AS driver,
         d.status AS current_status,
         COUNT(del.delivery_id) AS total_deliveries
     FROM fleet.drivers d
     JOIN operations.deliveries del ON d.driver_id = del.driver_id
     GROUP BY d.driver_name, d.status
     ORDER BY total_deliveries DESC
     LIMIT 10;"

append_markdown_table \
    "Delivery Status Summary" \
    "Delivery status counts show operational progress, bottlenecks, and the volume of work that still needs attention." \
    "SELECT
         delivery_status,
         COUNT(*) AS total_deliveries
     FROM operations.deliveries
     GROUP BY delivery_status
     ORDER BY total_deliveries DESC;"

append_markdown_table \
    "Pending Deliveries" \
    "Pending deliveries need operational follow-up to reduce customer delays and improve service reliability." \
    "SELECT
         del.delivery_id,
         del.order_id,
         c.full_name AS customer,
         d.driver_name AS assigned_driver,
         v.plate_number AS vehicle,
         del.delivery_status
     FROM operations.deliveries del
     JOIN operations.orders o ON del.order_id = o.order_id
     JOIN operations.customers c ON o.customer_id = c.customer_id
     JOIN fleet.drivers d ON del.driver_id = d.driver_id
     JOIN fleet.vehicles v ON del.vehicle_id = v.vehicle_id
     WHERE del.delivery_status = 'Pending'
     ORDER BY del.delivery_id
     LIMIT 20;"

append_markdown_table \
    "Revenue Summary" \
    "This section provides a high-level revenue view based on order totals." \
    "SELECT
         COUNT(*) AS total_orders,
         TO_CHAR(SUM(total_amount), 'FM999,999,999,990.00') AS total_revenue,
         TO_CHAR(AVG(total_amount), 'FM999,999,999,990.00') AS average_order_value,
         TO_CHAR(MIN(total_amount), 'FM999,999,999,990.00') AS lowest_order_value,
         TO_CHAR(MAX(total_amount), 'FM999,999,999,990.00') AS highest_order_value
     FROM operations.orders;"

append_markdown_table \
    "Payment Status Summary" \
    "Payment status counts help finance track successful payments, pending transactions, failures, and refunds." \
    "SELECT
         payment_status,
         COUNT(*) AS total_payments
     FROM finance.payments
     GROUP BY payment_status
     ORDER BY total_payments DESC;"

append_markdown_table \
    "Low Inventory Items" \
    "These products are below the stock threshold and should be reviewed for replenishment." \
    "SELECT
         w.warehouse_name,
         w.location,
         i.product_name,
         i.quantity
     FROM warehouse.inventory i
     JOIN warehouse.warehouses w ON i.warehouse_id = w.warehouse_id
     WHERE i.quantity < 20
     ORDER BY i.quantity ASC, w.warehouse_name
     LIMIT 25;"

append_markdown_table \
    "Cross-Schema Operational View" \
    "This combined view gives management end-to-end visibility from customer order to delivery and payment status." \
    "SELECT
         c.full_name AS customer,
         o.order_id,
         d.driver_name AS driver,
         v.plate_number AS vehicle,
         p.payment_status,
         del.delivery_status
     FROM operations.customers c
     JOIN operations.orders o ON c.customer_id = o.customer_id
     JOIN operations.deliveries del ON o.order_id = del.order_id
     JOIN fleet.drivers d ON del.driver_id = d.driver_id
     JOIN fleet.vehicles v ON del.vehicle_id = v.vehicle_id
     JOIN finance.payments p ON o.order_id = p.order_id
     ORDER BY o.order_id
     LIMIT 25;"

{
    printf '\n## Recommended Management Actions\n\n'
    printf -- '- Prioritize follow-up on pending deliveries.\n'
    printf -- '- Review low inventory items and restock where required.\n'
    printf -- '- Monitor failed, pending, and refunded payments with the finance team.\n'
    printf -- '- Use high-value customer insights to plan retention and loyalty offers.\n'
    printf -- '- Use driver workload data to balance assignments and recognize strong performance.\n'
} >> "$TMP_REPORT_FILE"

mv "$TMP_REPORT_FILE" "$REPORT_FILE"
echo "Management report created: ${REPORT_FILE}"
