with orders as (
    select
        customer_key,
        order_id,
        date_trunc('month', order_date)::date as order_month
    from {{ ref('fact_orders') }}
    where is_delivered
),

first_order as (
    select
        customer_key,
        min(order_month) as cohort_month
    from orders
    group by 1
),

cohort_activity as (
    select
        f.cohort_month,
        o.order_month,
        (
            extract(year from age(o.order_month, f.cohort_month)) * 12
            + extract(month from age(o.order_month, f.cohort_month))
        )::integer as months_since_first_order,
        count(distinct o.customer_key) as active_customers
    from orders o
    join first_order f
        on o.customer_key = f.customer_key
    group by 1, 2, 3
),

cohort_size as (
    select
        cohort_month,
        count(distinct customer_key) as cohort_customers
    from first_order
    group by 1
)

select
    a.cohort_month,
    a.order_month,
    a.months_since_first_order,
    s.cohort_customers,
    a.active_customers,
    a.active_customers::numeric / nullif(s.cohort_customers, 0) as retention_rate
from cohort_activity a
join cohort_size s
    on a.cohort_month = s.cohort_month