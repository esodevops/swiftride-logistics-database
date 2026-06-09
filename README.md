# SwiftRide Logistics PostgreSQL Dataset

SwiftRide Logistics is a PostgreSQL database project for a logistics and delivery company. It includes database schemas, CSV datasets, SQL query exercises, Supabase import scripts, and management-ready reports.

The project models operational workflows across customers, orders, deliveries, drivers, vehicles, warehouses, inventory, and payments.

## Project Contents

| Path | Purpose |
| --- | --- |
| `dataset/` | CSV source data for all database tables. |
| `ddl/` | Data Definition Language SQL for creating schemas and tables. |
| `dml/` | Data Manipulation Language SQL for constraint updates and data rules. |
| `dql/` | Data Query Language SQL for analysis and reporting queries. |
| `dcl/` | Data Control Language SQL for role and schema access management. |
| `docs/` | Source presentation PDF and ERD image. |
| `requirements/` | Organized project requirements extracted from the SwiftRide PDF. |
| `reports/` | Generated management reports in Markdown and PDF formats. |
| `scripts/` | Automation scripts for import, queries, and report generation. |

## Database Design

The database is organized into four PostgreSQL schemas:

| Schema | Description | Main Tables |
| --- | --- | --- |
| `operations` | Core business transactions and delivery workflow. | `customers`, `orders`, `deliveries` |
| `fleet` | Drivers and vehicles used for deliveries. | `drivers`, `vehicles` |
| `warehouse` | Warehouse locations and inventory stock. | `warehouses`, `inventory` |
| `finance` | Payment and financial transaction records. | `payments` |

## Source Data

The CSV files are stored in `dataset/` and should be imported in this order to satisfy foreign-key relationships:

1. `dataset/customers.csv`
2. `dataset/drivers.csv`
3. `dataset/vehicles.csv`
4. `dataset/warehouses.csv`
5. `dataset/orders.csv`
6. `dataset/deliveries.csv`
7. `dataset/inventory.csv`
8. `dataset/payments.csv`

## Requirements Documentation

The extracted SwiftRide project requirements are available from:

- [Requirements.md](Requirements.md)
- [requirements/01_project_overview.md](requirements/01_project_overview.md)
- [requirements/02_learning_objectives.md](requirements/02_learning_objectives.md)
- [requirements/03_case_study_and_problem_statement.md](requirements/03_case_study_and_problem_statement.md)
- [requirements/04_database_schema_requirements.md](requirements/04_database_schema_requirements.md)
- [requirements/05_business_value_and_rationale.md](requirements/05_business_value_and_rationale.md)

## Supabase Setup

Create a private `.env.supabase` file from the example:

```bash
cp .env.supabase.example .env.supabase
```

Then update `.env.supabase` with your Supabase database connection string:

```bash
SUPABASE_DB_URL="postgresql://postgres.<PROJECT_REF>:<YOUR_DB_PASSWORD>@aws-1-eu-north-1.pooler.supabase.com:5432/postgres"
```

If your password contains special characters such as `#`, URL-encode them. For example, `#` becomes `%23`.

Never commit `.env.supabase`; it contains private database credentials.

## Importing Data

For a fresh Supabase database, run:

```bash
scripts/import_to_supabase.sh --init-schema
```

For an existing database where the tables already exist and you want to reload the CSV data:

```bash
scripts/import_to_supabase.sh --reset
```

The import script:

- loads `.env.supabase` automatically
- creates schemas and tables when `--init-schema` is used
- applies constraint updates from `dml/Swift_logistics_dml.sql`
- imports CSV files in foreign-key-safe order
- repairs PostgreSQL `SERIAL` sequences after loading explicit IDs
- validates row counts after import

## Running SQL Queries

To run the analytical DQL queries:

```bash
scripts/queries.sh
```

This executes:

```text
dql/Swiftride_logistics_dql.sql
```

The query file includes:

- table row counts
- sample records
- high-value customer analysis
- driver delivery workload analysis
- pending delivery detection
- revenue analysis
- payment status analysis
- low inventory detection
- warehouse inventory reporting
- cross-schema operational reporting

## Management Reports

This project includes management-ready reporting outputs.

| Report | File |
| --- | --- |
| Markdown management report | [reports/swiftride_management_report.md](reports/swiftride_management_report.md) |
| Color PDF management report | [reports/swiftride_management_report.pdf](reports/swiftride_management_report.pdf) |

To regenerate the Markdown report:

```bash
scripts/management_report.sh
```

To regenerate the color PDF report:

```bash
scripts/management_report_pdf.sh
```

The management reports summarize:

- database coverage
- top high-value customers
- driver delivery workload
- delivery status summary
- pending deliveries
- revenue summary
- payment status summary
- low inventory items
- cross-schema operational visibility
- recommended management actions

## Key SQL Files

| File | Description |
| --- | --- |
| `ddl/Swiftride_logistics_ddl_solutions_db.sql` | Creates schemas and tables. |
| `dml/Swift_logistics_dml.sql` | Updates status constraints to match the dataset. |
| `dql/Swiftride_logistics_dql.sql` | Runs operational and business analysis queries. |
| `dcl/finance_schema_access_dcl.sql` | Creates and grants finance-schema access for a finance role. |

## Useful Commands

Check importer help:

```bash
scripts/import_to_supabase.sh --help
```

Check query runner help:

```bash
scripts/queries.sh --help
```

Check PDF report help:

```bash
scripts/management_report_pdf.sh --help
```

Run a SQL file manually:

```bash
source .env.supabase
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f dql/Swiftride_logistics_dql.sql
```

## Security Notes

- Do not commit `.env.supabase`.
- Do not hardcode real database passwords in SQL, shell, or Markdown files.
- Use placeholders in documentation and examples.
- Use Supabase dashboard roles and PostgreSQL roles carefully when granting access.

## Additional Guide

For a more detailed import walkthrough, see:

- [README_IMPORT_GUIDE.txt](README_IMPORT_GUIDE.txt)

