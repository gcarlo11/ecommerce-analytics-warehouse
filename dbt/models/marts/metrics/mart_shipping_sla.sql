with shipping as (
    select * from {{ ref('fact_shipping') }}
)

select
    order_date,
    count(distinct order_id) as order_count,
    count(distinct case when is_delivered then order_id end) as delivered_order_count,
    count(distinct case when is_late_delivery then order_id end) as late_delivery_count,
    avg(days_to_deliver) as average_days_to_deliver,
    avg(delivery_delta_days) as average_delivery_delta_days,
    case
        when count(distinct case when is_delivered then order_id end) = 0 then 0
        else count(distinct case when is_delivered and not is_late_delivery then order_id end)::numeric
            / count(distinct case when is_delivered then order_id end)
    end as on_time_delivery_rate
from shipping
group by 1