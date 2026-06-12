with sellers as (
    select * from {{ ref('stg_sellers') }}
)

select
    {{ generate_surrogate_key(["seller_id"]) }} as seller_key,
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
from sellers