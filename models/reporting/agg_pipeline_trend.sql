{{ config(materialized='table') }}

select
    to_char(date_trunc('month', close_date), 'Mon YYYY') as close_month,
    date_trunc('month', close_date) as close_month_date,

    count(distinct opportunity_id) as total_opportunities,

    sum(current_acv) as current_pipeline,
    sum(total_product_acv) as proposed_pipeline,
    sum(acv_difference) as pipeline_gap,

    count(distinct case when has_quote = 'Yes' then opportunity_id end) * 1.0 
        / count(distinct opportunity_id) as quote_coverage_pct,

    count(distinct case when has_ps = 'Yes' then opportunity_id end) * 1.0 
        / count(distinct opportunity_id) as ps_coverage_pct,

    count(distinct case when acv_validation_flag = 'Match' then opportunity_id end) * 1.0 
        / count(distinct opportunity_id) as acv_match_pct,

  
    case 
        when count(distinct case when stage_name like '%Closed Won%' 
                                   or stage_name like '%Closed Lost%' 
                              then opportunity_id end) = 0 
        then 0
        else 
            count(distinct case when stage_name like '%Closed Won%' then opportunity_id end) * 1.0
            /
            count(distinct case when stage_name like '%Closed Won%' 
                                   or stage_name like '%Closed Lost%' 
                              then opportunity_id end)
    end as win_rate

from {{ ref('combined_fct_pipeline_product') }}

group by close_month, close_month_date
order by close_month_date