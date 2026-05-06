{{ config(materialized='table') }}

select
    count(*) as total_opportunities,

    sum(current_acv) as total_pipeline,
    sum(total_product_acv) as proposed_pipeline,
    sum(acv_difference) as pipeline_gap,

    count(case when has_quote = 'Yes' then 1 end) * 1.0 / count(*) as quote_coverage_pct,
    count(case when has_ps = 'Yes' then 1 end) * 1.0 / count(*) as ps_coverage_pct,
    count(case when total_product_acv > 0 then 1 end) * 1.0 / count(*) as product_coverage_pct,

    count(case when acv_validation_flag = 'Match' then 1 end) * 1.0 / count(*) as acv_match_pct,
    sum(case when acv_validation_flag = 'Mismatch' then current_acv else 0 end) as pipeline_at_risk,

 
    sum(case when lower(stage_name) not like '%closed%' then total_product_acv else 0 end) as open_pipeline,
    sum(case when lower(stage_name) like '%won%' then total_product_acv else 0 end) as won_pipeline,
    sum(case when lower(stage_name) like '%lost%' then total_product_acv else 0 end) as lost_pipeline,

    count(case when lower(stage_name) like '%won%' then 1 end) * 1.0 /
    nullif(count(case when lower(stage_name) like '%closed%' then 1 end), 0) as win_rate,

    avg(current_acv) as avg_deal_size,

    count(case when has_ps = 'Yes' and lower(stage_name) not like '%closed%' then 1 end) * 1.0 /
    nullif(count(case when lower(stage_name) not like '%closed%' then 1 end), 0) as ps_coverage_open_pct

from {{ ref('combined_fct_pipeline_product') }}