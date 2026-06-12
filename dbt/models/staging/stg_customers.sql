with source as (
    select * from {{ source('olist_raw', 'raw_olist_customers') }}
)

select distinct
    nullif(customer_id, '') as customer_id,
    nullif(customer_unique_id, '') as customer_unique_id,
    nullif(customer_zip_code_prefix, '')::integer as customer_zip_code_prefix,
    lower(nullif(customer_city, '')) as customer_city,
    upper(nullif(customer_state, '')) as customer_state,
    nullif(loaded_at, '')::timestamptz as loaded_at,
    source_file,
    nullif(batch_date, '')::date as batch_date
from source