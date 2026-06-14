# ADR-001: Use Local PostgreSQL and dbt Core for MVP

## Status
Accepted

## Context
The project is intended for a beginner-friendly data engineering portfolio. It should be reproducible without paid cloud resources.

## Decision
Use PostgreSQL in Docker as the local warehouse and dbt Core with dbt-postgres for transformation.

## Consequences
Pros:
- Free and easy to run locally.
- Demonstrates SQL, dimensional modeling, testing, and CI.
- Maps well to cloud warehouses conceptually.

Cons:
- Does not demonstrate distributed warehouse features.
- Performance differs from BigQuery/Snowflake/Redshift.

## Future Extension
Add migration notes for BigQuery or Snowflake.