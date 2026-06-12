with source as (
    select * from {{ source('olist_raw', 'raw_olist_order_payments') }}
),

renamed as (
    select
        nullif(order_id, '') as order_id,
        nullif(payment_sequential, '')::integer as payment_sequential,
        lower(nullif(payment_type, '')) as payment_type,
        nullif(payment_installments, '')::integer as payment_installments,
        nullif(payment_value, '')::numeric(18, 2) as payment_value,
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
                partition by order_id, payment_sequential
                order by loaded_at desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    loaded_at,
    source_file,
    batch_date
from deduped