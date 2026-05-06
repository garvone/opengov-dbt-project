{{ config(materialized='table') }}

select
    stage_name,
    opportunity_type,

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

    sum(case when acv_validation_flag = 'Mismatch' then current_acv else 0 end) as pipeline_at_risk,

    avg(current_acv) as avg_deal_size,

    count(distinct case when ps_quote_alignment = 'Aligned' then opportunity_id end) * 1.0 
        / count(distinct opportunity_id) as aligned_pct,

    count(distinct case when ps_quote_alignment = 'Quote without PS' then opportunity_id end) * 1.0 
        / count(distinct opportunity_id) as quote_without_ps_pct,

    count(distinct case when ps_quote_alignment = 'PS without Quote' then opportunity_id end) * 1.0 
        / count(distinct opportunity_id) as ps_without_quote_pct

from {{ ref('combined_fct_pipeline_product') }}

group by stage_name, opportunity_type