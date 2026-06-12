with items as (
    select * from {{ ref('stg_order_items') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

item_agg as (
    select
        order_id,
        count(*) as item_count,
        sum(price) as order_item_value,
        sum(freight_value) as freight_value
    from items
    group by 1
),

payment_agg as (
    select
        order_id,
        count(*) as payment_count,
        sum(payment_value) as total_payment_value,
        max(payment_installments) as max_payment_installments
    from payments
    group by 1
)

select
    coalesce(i.order_id, p.order_id) as order_id,
    coalesce(i.item_count, 0) as item_count,
    coalesce(i.order_item_value, 0) as order_item_value,
    coalesce(i.freight_value, 0) as freight_value,
    coalesce(p.payment_count, 0) as payment_count,
    coalesce(p.total_payment_value, 0) as total_payment_value,
    coalesce(p.max_payment_installments, 0) as max_payment_installments
from item_agg i
full outer join payment_agg p
    on i.order_id = p.order_id