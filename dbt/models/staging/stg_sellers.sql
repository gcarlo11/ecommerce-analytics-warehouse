with source as (
    select * from {{ source('olist_raw', 'raw_olist_sellers') }}
),

renamed as (
    select
        nullif(seller_id, '') as seller_id,
        nullif(seller_zip_code_prefix, '')::integer as seller_zip_code_prefix,
        lower(nullif(seller_city, '')) as seller_city,
        upper(nullif(seller_state, '')) as seller_state,
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
                partition by seller_id
                order by loaded_at desc, source_file desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    loaded_at,
    source_file,
    batch_date
from deduped