{{ config(materialized='table') }}

with base as (

    select
        opportunity_id,
        stage_name,

        coalesce(bp_acv,0) as bp_acv,
        coalesce(eam_acv,0) as eam_acv,
        coalesce(fin_acv,0) as fin_acv,
        coalesce(gab_acv,0) as gab_acv,
        coalesce(plc_acv,0) as plc_acv,
        coalesce(pro_acv,0) as pro_acv,

        coalesce(bp_hours,0) as bp_hours,
        coalesce(eam_hours,0) as eam_hours,
        coalesce(fin_hours,0) as fin_hours,
        coalesce(gab_hours,0) as gab_hours,
        coalesce(plc_hours,0) as plc_hours,
        coalesce(pro_hours,0) as pro_hours

    from {{ ref('combined_fct_pipeline_product') }}

),

unpivot as (

    select opportunity_id, stage_name, 'bp' as product, bp_acv as acv, bp_hours as ps_hours from base
    union all
    select opportunity_id, stage_name, 'eam', eam_acv, eam_hours from base
    union all
    select opportunity_id, stage_name, 'fin', fin_acv, fin_hours from base
    union all
    select opportunity_id, stage_name, 'gab', gab_acv, gab_hours from base
    union all
    select opportunity_id, stage_name, 'plc', plc_acv, plc_hours from base
    union all
    select opportunity_id, stage_name, 'pro', pro_acv, pro_hours from base

),

filtered as (

    select *
    from unpivot
    where acv > 0 or ps_hours > 0

)

select
    product,

    case 
        when stage_name like '%Closed Won%' then 'Won'
        when stage_name like '%Closed Lost%' then 'Lost'
        else 'Open'
    end as opportunity_status,

    count(distinct opportunity_id) as total_opportunities,

    sum(acv) as product_pipeline,
    sum(ps_hours) as total_ps_hours,

    avg(ps_hours) as avg_ps_hours_per_deal,

    sum(case when ps_hours > 0 then ps_hours else 0 end) as scoped_ps_hours,

    count(case when ps_hours > 0 then 1 end) * 1.0 / count(*) as ps_coverage_pct

from filtered
group by product, opportunity_status