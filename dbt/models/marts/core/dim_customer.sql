with customers as (
    select * from {{ ref('stg_customers') }}
),

history as (
    select * from {{ ref('int_customer_order_history') }}
)

select
    {{ generate_surrogate_key(["c.customer_id"]) }} as customer_key,
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    h.first_order_date,
    h.last_order_date,
    h.total_orders,
    h.delivered_orders
from customers c
left join history h
    on c.customer_unique_id = h.customer_unique_id