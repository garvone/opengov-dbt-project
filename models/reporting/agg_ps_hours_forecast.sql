{{ config(materialized='table') }}

with base as (

    select *
    from {{ ref('combined_fct_pipeline_product') }}

),

filtered as (

    select
        opportunity_id,
        stage_name,

        bp_hours,
        eam_hours,
        fin_hours,
        gab_hours,
        plc_hours,
        pro_hours

    from base

    where 
        stage_name like '6.%'
        or stage_name like '7.%'
        or stage_name like '8.%'

),

unpivoted as (

    select opportunity_id, stage_name, 'BP'  as product, coalesce(bp_hours,0)  as ps_hours from filtered
    union all
    select opportunity_id, stage_name, 'EAM', coalesce(eam_hours,0) from filtered
    union all
    select opportunity_id, stage_name, 'FIN', coalesce(fin_hours,0) from filtered
    union all
    select opportunity_id, stage_name, 'GAB', coalesce(gab_hours,0) from filtered
    union all
    select opportunity_id, stage_name, 'PLC', coalesce(plc_hours,0) from filtered
    union all
    select opportunity_id, stage_name, 'PRO', coalesce(pro_hours,0) from filtered

)

select
    stage_name,
    product,
    sum(ps_hours) as total_ps_hours,
    count(distinct opportunity_id) as total_deals

from unpivoted

group by
    stage_name,
    product

order by
    stage_name,
    total_ps_hours desc