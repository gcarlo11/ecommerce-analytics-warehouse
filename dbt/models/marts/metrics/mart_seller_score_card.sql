with items as (
    select * from {{ ref('fact_order_items') }}
),

orders as (
    select * from {{ ref('fact_orders') }}
),

sellers as (
    select * from {{ ref('dim_seller') }}
),

joined as (
    select
        i.seller_key,
        s.seller_id,
        s.seller_city,
        s.seller_state,
        i.order_id,
        i.price,
        i.freight_value,
        o.avg_review_score,
        o.is_late_delivery
    from items i
    left join orders o
        on i.order_id = o.order_id
    left join sellers s
        on i.seller_key = s.seller_key
)

select
    seller_key,
    seller_id,
    seller_city,
    seller_state,
    count(distinct order_id) as order_count,
    sum(price) as gross_revenue,
    avg(avg_review_score) as average_review_score,
    avg(case when is_late_delivery then 1 else 0 end) as late_delivery_rate
from joined
group by 1, 2, 3, 4