with source as (
    select * from {{ source('olist_raw', 'raw_olist_customers') }}
),

renamed as (
    select
        nullif(customer_id, '') as customer_id,
        nullif(customer_unique_id, '') as customer_unique_id,
        nullif(customer_zip_code_prefix, '')::integer as customer_zip_code_prefix,
        lower(nullif(customer_city, '')) as customer_city,
        upper(nullif(customer_state, '')) as customer_state,
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
                partition by customer_id
                order by loaded_at desc, source_file desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    loaded_at,
    source_file,
    batch_date
from deduped