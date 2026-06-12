with source as (
    select * from {{ source('olist_raw', 'raw_olist_orders') }}
),

renamed as (
    select
        nullif(order_id, '') as order_id,
        nullif(customer_id, '') as customer_id,
        lower(nullif(order_status, '')) as order_status,
        nullif(order_purchase_timestamp, '')::timestamp as order_purchase_timestamp,
        nullif(order_approved_at, '')::timestamp as order_approved_at,
        nullif(order_delivered_carrier_date, '')::timestamp as order_delivered_carrier_date,
        nullif(order_delivered_customer_date, '')::timestamp as order_delivered_customer_date,
        nullif(order_estimated_delivery_date, '')::timestamp as order_estimated_delivery_date,
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
                partition by order_id
                order by loaded_at desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    loaded_at,
    source_file,
    batch_date
from deduped