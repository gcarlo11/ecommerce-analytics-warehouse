# Architecture: E-commerce Analytics Warehouse

## Purpose
This project transforms Olist e-commerce CSV data into a reproducible analytics warehouse with tested dimensional models and business metric marts.

## Components
- Python loader ingests CSV files into PostgreSQL raw schema.
- dbt transforms raw data into staging, intermediate, facts, dimensions, and marts.
- Metabase reads metric marts for dashboards.
- GitHub Actions validates loader and dbt transformations in CI.

## Data Flow
CSV -> raw schema -> staging -> intermediate -> marts -> dashboard

## Design Principles
- Raw data remains close to source.
- Business logic lives in dbt, not in BI charts.
- Every fact table has explicit grain.
- KPI definitions are documented in a metric catalog.
- CI fails when data contracts break.