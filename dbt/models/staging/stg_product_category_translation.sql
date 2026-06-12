with source as (
    select * from {{ source('olist_raw', 'raw_product_category_name_translation') }}
)

select distinct
    lower(nullif(product_category_name, '')) as product_category_name,
    lower(nullif(product_category_name_english, '')) as product_category_name_english,
    nullif(loaded_at, '')::timestamptz as loaded_at,
    source_file,
    nullif(batch_date, '')::date as batch_date
from source