# Case Study: E-commerce Analytics Warehouse

## Problem
Marketplace teams need reliable sales, customer, product, seller, and shipping KPIs. Raw CSV data is not suitable for direct dashboarding because business logic, grain, and data quality rules are unclear.

## Solution
I built a reproducible analytics warehouse using PostgreSQL, dbt Core, Docker, and Metabase. The pipeline loads Olist CSV data into raw tables, transforms it into dimensional models, validates assumptions with dbt tests, and exposes metric marts for dashboards.

## Architecture
CSV -> Python Loader -> PostgreSQL Raw -> dbt Staging -> dbt Intermediate -> Facts/Dimensions -> Metric Marts -> Metabase Dashboard

## Key Engineering Decisions
- Used PostgreSQL locally for reproducibility and zero cloud cost.
- Used dbt for SQL transformation, lineage, and data tests.
- Kept raw data close to source and moved business logic into dbt.
- Documented metric definitions to avoid KPI ambiguity.
- Added CI/CD validation with GitHub Actions.

## Business Impact
The warehouse supports analysis of revenue trends, AOV, cancellation rate, customer RFM segments, cohort retention, product performance, seller scorecards, and shipping SLA.

## What I Learned
- Designing facts and dimensions requires explicit grain.
- Data quality checks are business contracts, not just technical tests.
- Public snapshot datasets need careful simulation to demonstrate incremental workflows.
- BI dashboards should read from governed metric marts, not raw tables.