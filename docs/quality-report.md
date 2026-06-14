# Data Quality Report

## Scope
This report summarizes quality checks for the e-commerce analytics warehouse.

## dbt Tests
- Primary key uniqueness checks on dimensions and facts.
- Not-null checks on business keys.
- Accepted values checks for order status, payment type, and RFM segment.
- Reconciliation test between sales mart and order item facts.

## Latest Result
Date: YYYY-MM-DD
Command: `dbt build --project-dir dbt`
Status: PASS/FAIL

## Known Data Caveats
- Olist is a historical public snapshot, not a live production feed.
- Incremental loading is simulated using order purchase date.
- Revenue is product item revenue and does not represent net profit.
- Freight value is treated as shipping charge, not shipping margin.

## Remediation Workflow
1. Read failing dbt test.
2. Open compiled SQL in `dbt/target/compiled`.
3. Query failing records in PostgreSQL.
4. Decide whether the issue is source data, transformation logic, or metric definition.
5. Fix SQL or update metric catalog.