with source as (
    select * from {{ source('olist_raw', 'raw_olist_products') }}
),

renamed as (
    select
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
),

deduped as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by product_id
                order by loaded_at desc, source_file desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    loaded_at,
    source_file,
    batch_date
from deduped