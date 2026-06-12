with source as (
    select * from {{ source('olist_raw', 'raw_olist_order_reviews') }}
),

renamed as (
    select
        nullif(review_id, '') as review_id,
        nullif(order_id, '') as order_id,
        nullif(review_score, '')::integer as review_score,
        nullif(review_comment_title, '') as review_comment_title,
        nullif(review_comment_message, '') as review_comment_message,
        nullif(review_creation_date, '')::timestamp as review_creation_date,
        nullif(review_answer_timestamp, '')::timestamp as review_answer_timestamp,
        nullif(loaded_at, '')::timestamptz as loaded_at,
        source_file,
        nullif(batch_date, '')::date as batch_date
    from source
),

deduped as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by review_id, order_id
                order by loaded_at desc
            ) as row_num
        from renamed
    ) as ranked
    where row_num = 1
)

select
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    loaded_at,
    source_file,
    batch_date
from deduped