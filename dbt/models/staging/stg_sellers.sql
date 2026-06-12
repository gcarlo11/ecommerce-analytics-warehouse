with source as (
    select * from {{ source('olist_raw', 'raw_olist_sellers') }}
)

select distinct
    nullif(seller_id, '') as seller_id,
    nullif(seller_zip_code_prefix, '')::integer as seller_zip_code_prefix,
    lower(nullif(seller_city, '')) as seller_city,
    upper(nullif(seller_state, '')) as seller_state,
    nullif(loaded_at, '')::timestamptz as loaded_at,
    source_file,
    nullif(batch_date, '')::date as batch_date
from source