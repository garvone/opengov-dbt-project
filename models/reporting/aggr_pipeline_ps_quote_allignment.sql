{{ config(materialized='table') }}

select
    ps_quote_alignment,


    count(distinct opportunity_id) as total_opportunities,


    sum(current_acv) as total_pipeline,


    count(distinct case 
        when stage_name ilike '%Closed Won%' then opportunity_id 
    end) as won_opportunities,


    count(distinct case 
        when stage_name ilike '%Closed Won%' then opportunity_id 
    end) * 1.0 
    / nullif(count(distinct opportunity_id),0) as won_opportunity_pct,


    sum(case 
        when stage_name ilike '%Closed Won%' then current_acv 
        else 0 
    end) as won_pipeline,

    sum(case 
        when stage_name ilike '%Closed Won%' then current_acv 
        else 0 
    end) * 1.0 
    / nullif(sum(current_acv),0) as won_pipeline_pct,


    count(distinct case 
        when stage_name ilike '%Closed Lost%' then opportunity_id 
    end) * 1.0 
    / nullif(count(distinct opportunity_id),0) as lost_opportunity_pct,

    -- Open % (optional but useful)
    count(distinct case 
        when stage_name not ilike '%Closed Won%' 
         and stage_name not ilike '%Closed Lost%' 
        then opportunity_id 
    end) * 1.0 
    / nullif(count(distinct opportunity_id),0) as open_opportunity_pct,

    sum(current_acv) * 1.0 
    / sum(sum(current_acv)) over () as pipeline_share_pct

from {{ ref('combined_fct_pipeline_product') }}

group by ps_quote_alignment