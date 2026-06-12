with orders as (
    select * from {{ ref('stg_orders') }}
),

financials as (
    select * from {{ ref('int_order_financials') }}
),

fulfillment as (
    select * from {{ ref('int_order_fulfillment') }}
),

reviews as (
    select
        order_id,
        avg(review_score)::numeric(10, 2) as avg_review_score
    from {{ ref('stg_reviews') }}
    group by 1
),

customers as (
    select customer_id, customer_key
    from {{ ref('dim_customer') }}
)

select
    {{ generate_surrogate_key(["o.order_id"]) }} as order_key,
    o.order_id,
    c.customer_key,
    o.customer_id,
    o.order_purchase_timestamp::date as order_date,
    o.order_status,
    f.item_count,
    f.order_item_value as order_value,
    f.freight_value,
    f.payment_count,
    f.total_payment_value,
    r.avg_review_score,
    ff.is_delivered,
    ff.is_cancelled,
    ff.days_to_approve,
    ff.days_to_deliver,
    ff.delivery_delta_days,
    ff.is_late_delivery
from orders o
left join financials f
    on o.order_id = f.order_id
left join fulfillment ff
    on o.order_id = ff.order_id
left join reviews r
    on o.order_id = r.order_id
left join customers c
    on o.customer_id = c.customer_id