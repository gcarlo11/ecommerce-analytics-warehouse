with date_spine as (
    select generate_series(
        '2016-01-01'::date,
        '2019-12-31'::date,
        interval '1 day'
    )::date as date_day
)

select
    date_day as date_key,
    date_day,
    extract(day from date_day)::integer as day_of_month,
    extract(month from date_day)::integer as month_number,
    extract(quarter from date_day)::integer as quarter_number,
    extract(year from date_day)::integer as year_number,
    extract(dow from date_day)::integer as day_of_week_number,
    to_char(date_day, 'Day') as day_name,
    case when extract(dow from date_day) in (0, 6) then true else false end as is_weekend
from date_spine