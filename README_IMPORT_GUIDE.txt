SwiftRide Logistics PostgreSQL CSV Datasets
Each CSV contains at least 350 records. Import parent tables first to satisfy foreign keys.

Recommended import order:
- dataset/customers.csv
- dataset/drivers.csv
- dataset/vehicles.csv
- dataset/warehouses.csv
- dataset/orders.csv
- dataset/deliveries.csv
- dataset/inventory.csv
- dataset/payments.csv

PostgreSQL COPY example:
COPY operations.customers(customer_id, full_name, email, phone_number, city) FROM '/path/dataset/customers.csv' DELIMITER ',' CSV HEADER;

==================================================
SUPABASE SETUP (Recommended for this project)
==================================================

1) Create a Supabase project
- Go to Supabase Dashboard and create a new project.
- Wait until the project is fully provisioned.

2) Run schema SQL in Supabase
- Open SQL Editor in Supabase.
- Paste and run ddl/Swiftride_logistics_ddl_solutions_db.sql.
- Important: CREATE DATABASE is already commented out because Supabase manages the database for you.

3) Import CSVs in this order (foreign-key safe)
- dataset/customers.csv into operations.customers
- dataset/drivers.csv into fleet.drivers
- dataset/vehicles.csv into fleet.vehicles
- dataset/warehouses.csv into warehouse.warehouses
- dataset/orders.csv into operations.orders
- dataset/deliveries.csv into operations.deliveries
- dataset/inventory.csv into warehouse.inventory
- dataset/payments.csv into finance.payments

Option A: Supabase Dashboard import
- Open Table Editor -> select table -> Import data from CSV.
- Ensure CSV header row is enabled.

Option B: psql from your terminal
- Get credentials from Supabase: Project Settings -> Database -> Connection string.
- Use SSL mode required.

Template command:
psql "postgresql://postgres:<YOUR_DB_PASSWORD>@<YOUR_HOST>:5432/postgres?sslmode=require"

Then run these in psql (adjust absolute file paths):
\copy operations.customers(customer_id, full_name, email, phone_number, city) from '/absolute/path/dataset/customers.csv' with (format csv, header true);
\copy fleet.drivers(driver_id, driver_name, license_number, phone_number, status) from '/absolute/path/dataset/drivers.csv' with (format csv, header true);
\copy fleet.vehicles(vehicle_id, vehicle_type, plate_number, capacity) from '/absolute/path/dataset/vehicles.csv' with (format csv, header true);
\copy warehouse.warehouses(warehouse_id, warehouse_name, location) from '/absolute/path/dataset/warehouses.csv' with (format csv, header true);
\copy operations.orders(order_id, customer_id, order_date, delivery_address, total_amount) from '/absolute/path/dataset/orders.csv' with (format csv, header true);
\copy operations.deliveries(delivery_id, order_id, driver_id, vehicle_id, delivery_status) from '/absolute/path/dataset/deliveries.csv' with (format csv, header true);
\copy warehouse.inventory(inventory_id, warehouse_id, product_name, quantity) from '/absolute/path/dataset/inventory.csv' with (format csv, header true);
\copy finance.payments(payment_id, order_id, payment_method, payment_status) from '/absolute/path/dataset/payments.csv' with (format csv, header true);

4) Validate import counts
Run:
select count(*) from operations.customers;
select count(*) from fleet.drivers;
select count(*) from fleet.vehicles;
select count(*) from warehouse.warehouses;
select count(*) from operations.orders;
select count(*) from operations.deliveries;
select count(*) from warehouse.inventory;
select count(*) from finance.payments;

5) Security note
- Never store real database passwords inside SQL files in this repository.

6) One-command import script
- A ready-to-run loader is available at scripts/import_to_supabase.sh
- Copy .env.supabase.example to .env.supabase and replace the placeholders with your Supabase connection string.
- First run on a fresh Supabase project:
	SUPABASE_DB_URL="postgresql://postgres:<YOUR_DB_PASSWORD>@<YOUR_HOST>:5432/postgres?sslmode=require" scripts/import_to_supabase.sh --init-schema
- Re-import into an existing project and clear current data first:
	SUPABASE_DB_URL="postgresql://postgres:<YOUR_DB_PASSWORD>@<YOUR_HOST>:5432/postgres?sslmode=require" scripts/import_to_supabase.sh --reset
- Or, after creating .env.supabase:
	scripts/import_to_supabase.sh --init-schema
- The script imports all CSV files from dataset/, validates row counts, and repairs SERIAL sequences after loading explicit IDs.

7) Management reports
- Generate a Markdown management report:
	scripts/management_report.sh
- Generate a color PDF management report:
	scripts/management_report_pdf.sh
