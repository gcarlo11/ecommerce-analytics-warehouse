with orders as (
    select * from {{ ref('fact_orders') }}
)

select
    order_date,
    count(distinct order_id) as order_count,
    count(distinct case when is_delivered then order_id end) as delivered_order_count,
    count(distinct case when is_cancelled then order_id end) as cancelled_order_count,
    sum(case when is_delivered then order_value else 0 end) as gross_revenue,
    sum(case when is_delivered then freight_value else 0 end) as freight_revenue,
    case
        when count(distinct case when is_delivered then order_id end) = 0 then 0
        else sum(case when is_delivered then order_value else 0 end)
            / count(distinct case when is_delivered then order_id end)
    end as average_order_value,
    case
        when count(distinct order_id) = 0 then 0
        else count(distinct case when is_cancelled then order_id end)::numeric
            / count(distinct order_id)
    end as cancellation_rate,
    avg(avg_review_score) as average_review_score,
    avg(days_to_deliver) as average_days_to_deliver,
    case
        when count(distinct case when is_delivered then order_id end) = 0 then 0
        else count(distinct case when is_delivered and not is_late_delivery then order_id end)::numeric
            / count(distinct case when is_delivered then order_id end)
    end as on_time_delivery_rate
from orders
group by 1