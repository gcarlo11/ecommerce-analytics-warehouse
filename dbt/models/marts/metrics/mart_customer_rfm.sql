with orders as (
    select
        customer_key,
        customer_id,
        order_id,
        order_date,
        order_value
    from {{ ref('fact_orders') }}
    where is_delivered
),

rfm_base as (
    select
        customer_key,
        max(order_date) as last_order_date,
        count(distinct order_id) as frequency,
        sum(order_value) as monetary
    from orders
    group by 1
),

scored as (
    select
        *,
        ntile(5) over (order by last_order_date) as recency_score,
        ntile(5) over (order by frequency) as frequency_score,
        ntile(5) over (order by monetary) as monetary_score
    from rfm_base
)

select
    customer_key,
    last_order_date,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    case
        when recency_score >= 4 and frequency_score >= 4 and monetary_score >= 4 then 'champions'
        when frequency_score >= 4 and monetary_score >= 4 then 'loyal_high_value'
        when recency_score <= 2 and monetary_score >= 4 then 'at_risk_high_value'
        when frequency_score = 1 then 'one_time_buyer'
        else 'standard'
    end as rfm_segment
from scored