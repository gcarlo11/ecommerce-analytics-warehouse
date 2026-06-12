with source as (
    select * from {{ source('olist_raw', 'raw_product_category_name_translation') }}
),

renamed as (
    select
        lower(nullif(product_category_name, '')) as product_category_name,
        lower(nullif(product_category_name_english, '')) as product_category_name_english,
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
                partition by product_category_name
                order by loaded_at desc, source_file desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    product_category_name,
    product_category_name_english,
    loaded_at,
    source_file,
    batch_date
from deduped