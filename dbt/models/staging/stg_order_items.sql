with source as (
    select * from {{ source('olist_raw', 'raw_olist_order_items') }}
),

renamed as (
    select
        nullif(order_id, '') as order_id,
        nullif(order_item_id, '')::integer as order_item_id,
        nullif(product_id, '') as product_id,
        nullif(seller_id, '') as seller_id,
        nullif(shipping_limit_date, '')::timestamp as shipping_limit_date,
        nullif(price, '')::numeric(18, 2) as price,
        nullif(freight_value, '')::numeric(18, 2) as freight_value,
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
                partition by order_id, order_item_id
                order by loaded_at desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    loaded_at,
    source_file,
    batch_date
from deduped