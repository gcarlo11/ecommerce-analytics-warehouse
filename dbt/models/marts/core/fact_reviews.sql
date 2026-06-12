select
    {{ generate_surrogate_key(["review_id", "order_id"]) }} as review_key,
    review_id,
    order_id,
    review_score,
    review_creation_date::date as review_creation_date,
    review_answer_timestamp::date as review_answer_date,
    case
        when review_answer_timestamp is not null
        then extract(day from review_answer_timestamp - review_creation_date)
    end as review_response_days
from {{ ref('stg_reviews') }}