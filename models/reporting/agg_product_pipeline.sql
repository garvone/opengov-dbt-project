{{ config(materialized='table') }}

with base as (

    select
        opportunity_id,
        stage_name,
        upper(replace(product, '_ACV', '')) as product,  
        product_acv,
        current_acv,
        has_quote,
        has_ps,
        acv_validation_flag

    from {{ ref('combined_fct_pipeline_product') }}

    unpivot (
        product_acv for product in (
            bp_acv, eam_acv, fin_acv, gab_acv, plc_acv, pro_acv, other_acv
        )
    )

),

filtered as (

    select *
    from base
    where product_acv is not null
      and product_acv <> 0

),

agg as (

    select
        product,

        count(distinct opportunity_id) as total_opportunities,

        sum(product_acv) as product_pipeline,
        avg(product_acv) as avg_product_deal_size,

        count(distinct case when has_quote = 'Yes' then opportunity_id end) * 1.0 
            / count(distinct opportunity_id) as quote_coverage_pct,

        count(distinct case when has_ps = 'Yes' then opportunity_id end) * 1.0 
            / count(distinct opportunity_id) as ps_coverage_pct,

        count(distinct case when acv_validation_flag = 'Match' then opportunity_id end) * 1.0 
            / count(distinct opportunity_id) as acv_match_pct,

        sum(case when acv_validation_flag = 'Mismatch' then product_acv else 0 end) as pipeline_at_risk,

        count(distinct case when stage_name like '%Closed Won%' then opportunity_id end) as won_opportunities,
        count(distinct case when stage_name like '%Closed Lost%' then opportunity_id end) as lost_opportunities,
        count(distinct case when stage_name not like '%Closed%' then opportunity_id end) as open_opportunities,

        count(distinct case when stage_name like '%Closed Won%' then opportunity_id end) * 1.0 /
        nullif(count(distinct case when stage_name like '%Closed%' then opportunity_id end),0) as win_rate_pct,

        sum(case when stage_name like '%Closed Won%' then product_acv else 0 end) * 1.0 /
        nullif(sum(product_acv),0) as won_amount_pct,

        sum(case when stage_name like '%Closed Lost%' then product_acv else 0 end) * 1.0 /
        nullif(sum(product_acv),0) as lost_amount_pct,

        sum(case when stage_name not like '%Closed%' then product_acv else 0 end) * 1.0 /
        nullif(sum(product_acv),0) as open_pipeline_pct

    from filtered
    group by product

)

select * from agg