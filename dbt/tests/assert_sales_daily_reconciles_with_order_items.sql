with fact_revenue as (
    select
        order_date,
        sum(order_value) as revenue_from_delivered_orders
    from {{ ref('fact_orders') }}
    where is_delivered
    group by 1
),

mart_revenue as (
    select
        order_date,
        gross_revenue
    from {{ ref('mart_sales_daily') }}
),

comparison as (
    select
        f.order_date,
        f.revenue_from_delivered_orders,
        m.gross_revenue,
        abs(coalesce(f.revenue_from_delivered_orders, 0) - coalesce(m.gross_revenue, 0)) as diff
    from fact_revenue f
    join mart_revenue m
        on f.order_date = m.order_date
)

select *
from comparison
where diff > 0.01