# E-commerce Analytics Warehouse

Portfolio project that builds a reproducible analytics warehouse for Olist e-commerce data using PostgreSQL, dbt Core, Docker, Metabase, and GitHub Actions.

## Business Questions
- How are revenue, order count, AOV, and cancellation rate trending?
- Which products and sellers drive the most revenue?
- Which customer segments are most valuable?
- How strong is shipping SLA performance?
- How does cohort retention change over time?

## Architecture
CSV -> Python Loader -> PostgreSQL Raw Schema -> dbt Staging -> dbt Marts -> Metabase Dashboard

## Tech Stack
- Python
- PostgreSQL
- Docker Compose
- dbt Core
- Metabase
- GitHub Actions

## Quick Start
```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
docker compose up -d
python -m src.loader.load_olist --data-dir data/raw --mode snapshot
$env:DBT_PROFILES_DIR="profiles"
dbt build --project-dir dbt
dbt docs generate --project-dir dbt
dbt docs serve --project-dir dbt
```

## Dashboard
Metabase runs at:

```text
http://localhost:3000
```

## Data Model
- `dim_customer`
- `dim_product`
- `dim_seller`
- `dim_date`
- `fact_orders`
- `fact_order_items`
- `fact_payments`
- `fact_reviews`
- `fact_shipping`
- `mart_sales_daily`
- `mart_customer_rfm`
- `mart_retention_cohort`
- `mart_product_performance`
- `mart_seller_scorecard`
- `mart_shipping_sla`

## Data Quality
This project uses dbt data tests for:
- uniqueness
- not-null constraints
- accepted values
- reconciliation checks
- basic referential integrity

## Portfolio Highlights
- Designed a dimensional warehouse with documented grain.
- Built reproducible ingestion from CSV to raw schema.
- Implemented dbt transformations and tests.
- Created metric marts and dashboard-ready KPI tables.
- Added CI/CD validation with GitHub Actions.
```