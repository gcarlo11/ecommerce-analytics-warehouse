select
    {{ generate_surrogate_key(["order_id", "payment_sequential"]) }} as payment_key,
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
from {{ ref('stg_payments') }}