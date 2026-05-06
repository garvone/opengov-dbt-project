{{ config(materialized='table') }}

with opp as (

    select
        opportunity_id,
        opportunity_name,
        opportunity_type,
        stage_name,
        close_date,
        gross_acv,
        coalesce(is_bp,0) as is_bp,
        coalesce(is_eam,0) as is_eam,
        coalesce(is_fin,0) as is_fin,
        coalesce(is_gab,0) as is_gab,
        coalesce(is_plc,0) as is_plc,
        coalesce(is_pro,0) as is_pro

    from {{ ref('int_opportunities_clean') }}

),

suite as (

    select
        opportunity_id,
        bp_acv,
        eam_acv,
        fin_acv,
        gab_acv,
        plc_acv,
        pro_acv,
        other_acv,
        total_product_acv
    from {{ ref('int_suite_acv_clean') }}

),

ps as (

    select
        opportunity_id,

        sum(coalesce(bn_hours,0)) as bp_hours,
        sum(coalesce(eam_hours,0)) as eam_hours,
        sum(coalesce(fin_hours,0)) as fin_hours,
        sum(coalesce(gab_hours,0)) as gab_hours,
        sum(coalesce(plc_hours,0)) as plc_hours,
        sum(coalesce(pro_hours,0)) as pro_hours,

        sum(
            coalesce(bn_hours,0) +
            coalesce(eam_hours,0) +
            coalesce(fin_hours,0) +
            coalesce(gab_hours,0) +
            coalesce(plc_hours,0) +
            coalesce(pro_hours,0)
        ) as total_ps_hours

    from {{ ref('stg_ps_scopes') }}
    group by opportunity_id

)

select
    o.opportunity_id,
    o.opportunity_name,
    o.opportunity_type,
    o.stage_name,
    o.close_date,

    o.gross_acv as current_acv,


    s.bp_acv,
    s.eam_acv,
    s.fin_acv,
    s.gab_acv,
    s.plc_acv,
    s.pro_acv,
    s.other_acv,
    s.total_product_acv,


    p.bp_hours,
    p.eam_hours,
    p.fin_hours,
    p.gab_hours,
    p.plc_hours,
    p.pro_hours,
    p.total_ps_hours,


    o.is_bp,
    o.is_eam,
    o.is_fin,
    o.is_gab,
    o.is_plc,
    o.is_pro,

    case 
        when coalesce(s.total_product_acv,0) > 0 then 'Yes'
        else 'No'
    end as has_quote,

    case 
        when coalesce(p.total_ps_hours,0) > 0 then 'Yes'
        else 'No'
    end as has_ps,

    
    case 
        when abs(coalesce(o.gross_acv,0) - coalesce(s.total_product_acv,0)) <= 1 then 'Match'
        else 'Mismatch'
    end as acv_validation_flag,

    coalesce(s.total_product_acv,0) - coalesce(o.gross_acv,0) as acv_difference,

 
    case 
        when coalesce(p.total_ps_hours,0) > 0 and coalesce(s.total_product_acv,0) = 0 then 'PS without Quote'
        when coalesce(p.total_ps_hours,0) = 0 and coalesce(s.total_product_acv,0) > 0 then 'Quote without PS'
        when coalesce(p.total_ps_hours,0) > 0 and coalesce(s.total_product_acv,0) > 0 then 'Aligned'
        else 'No Activity'
    end as ps_quote_alignment

from opp o
left join suite s
    on o.opportunity_id = s.opportunity_id
left join ps p
    on o.opportunity_id = p.opportunity_id