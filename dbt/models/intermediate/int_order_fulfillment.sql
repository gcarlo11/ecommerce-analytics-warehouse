with orders as (
    select * from {{ ref('stg_orders') }}
)

select
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    case
        when order_approved_at is not null
        then extract(day from order_approved_at - order_purchase_timestamp)
    end as days_to_approve,
    case
        when order_delivered_customer_date is not null
        then extract(day from order_delivered_customer_date - order_purchase_timestamp)
    end as days_to_deliver,
    case
        when order_delivered_customer_date is not null
        then extract(day from order_estimated_delivery_date - order_delivered_customer_date)
    end as delivery_delta_days,
    case
        when order_delivered_customer_date is not null
             and order_delivered_customer_date > order_estimated_delivery_date
        then true
        else false
    end as is_late_delivery,
    case when order_status = 'delivered' then true else false end as is_delivered,
    case when order_status = 'canceled' then true else false end as is_cancelled
from orders