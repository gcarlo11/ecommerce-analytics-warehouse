with items as (
    select * from {{ ref('fact_order_items') }}
),

products as (
    select * from {{ ref('dim_product') }}
)

select
    p.product_category_name_english,
    count(distinct i.order_id) as order_count,
    count(*) as item_count,
    sum(i.price) as gross_revenue,
    sum(i.freight_value) as freight_revenue,
    avg(i.price) as average_item_price
from items i
left join products p
    on i.product_key = p.product_key
group by 1