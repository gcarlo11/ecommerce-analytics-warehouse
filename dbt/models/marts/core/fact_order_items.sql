with items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select order_id, order_purchase_timestamp::date as order_date
    from {{ ref('stg_orders') }}
),

products as (
    select product_id, product_key
    from {{ ref('dim_product') }}
),

sellers as (
    select seller_id, seller_key
    from {{ ref('dim_seller') }}
)

select
    {{ generate_surrogate_key(["i.order_id", "i.order_item_id"]) }} as order_item_key,
    i.order_id,
    i.order_item_id,
    o.order_date,
    p.product_key,
    s.seller_key,
    i.product_id,
    i.seller_id,
    i.shipping_limit_date,
    i.price,
    i.freight_value
from items i
left join orders o
    on i.order_id = o.order_id
left join products p
    on i.product_id = p.product_id
left join sellers s
    on i.seller_id = s.seller_id