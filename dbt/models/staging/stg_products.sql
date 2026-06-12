with source as (
    select * from {{ source('olist_raw', 'raw_olist_products') }}
)

select distinct
    nullif(product_id, '') as product_id,
    lower(nullif(product_category_name, '')) as product_category_name,
    nullif(product_name_lenght, '')::integer as product_name_length,
    nullif(product_description_lenght, '')::integer as product_description_length,
    nullif(product_photos_qty, '')::integer as product_photos_qty,
    nullif(product_weight_g, '')::integer as product_weight_g,
    nullif(product_length_cm, '')::integer as product_length_cm,
    nullif(product_height_cm, '')::integer as product_height_cm,
    nullif(product_width_cm, '')::integer as product_width_cm,
    nullif(loaded_at, '')::timestamptz as loaded_at,
    source_file,
    nullif(batch_date, '')::date as batch_date
from source