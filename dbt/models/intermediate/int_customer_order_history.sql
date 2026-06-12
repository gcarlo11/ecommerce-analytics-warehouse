with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

joined as (
    select
        c.customer_unique_id,
        o.customer_id,
        o.order_id,
        o.order_purchase_timestamp::date as order_date,
        o.order_status
    from orders o
    left join customers c
        on o.customer_id = c.customer_id
)

select
    customer_unique_id,
    min(order_date) as first_order_date,
    max(order_date) as last_order_date,
    count(distinct order_id) as total_orders,
    count(distinct case when order_status = 'delivered' then order_id end) as delivered_orders
from joined
group by 1