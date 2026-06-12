select
    {{ generate_surrogate_key(["order_id"]) }} as shipping_key,
    order_id,
    order_purchase_timestamp::date as order_date,
    order_approved_at::date as approved_date,
    order_delivered_carrier_date::date as delivered_carrier_date,
    order_delivered_customer_date::date as delivered_customer_date,
    order_estimated_delivery_date::date as estimated_delivery_date,
    days_to_approve,
    days_to_deliver,
    delivery_delta_days,
    is_late_delivery,
    is_delivered
from {{ ref('int_order_fulfillment') }}