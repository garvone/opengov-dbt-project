{{ config(materialized='table') }}

with base as (

    select *
    from FIVETRAN.DBT_GSRIVASTAVA.combined_fct_pipeline_product

),


unpivoted as (

    select
        opportunity_id,
        opportunity_name,
        stage_name,
        current_acv,

        'bp' as product,
        is_bp as is_flag,
        bp_acv as product_acv,


        bp_acv,
        eam_acv,
        fin_acv,
        gab_acv,
        plc_acv,
        pro_acv,
        other_acv

    from base

    union all

    select
        opportunity_id,
        opportunity_name,
        stage_name,
        current_acv,

        'eam',
        is_eam,
        eam_acv,

        bp_acv,
        eam_acv,
        fin_acv,
        gab_acv,
        plc_acv,
        pro_acv,
        other_acv

    from base

    union all

    select
        opportunity_id,
        opportunity_name,
        stage_name,
        current_acv,

        'fin',
        is_fin,
        fin_acv,

        bp_acv,
        eam_acv,
        fin_acv,
        gab_acv,
        plc_acv,
        pro_acv,
        other_acv

    from base

    union all

    select
        opportunity_id,
        opportunity_name,
        stage_name,
        current_acv,

        'gab',
        is_gab,
        gab_acv,

        bp_acv,
        eam_acv,
        fin_acv,
        gab_acv,
        plc_acv,
        pro_acv,
        other_acv

    from base

    union all

    select
        opportunity_id,
        opportunity_name,
        stage_name,
        current_acv,

        'plc',
        is_plc,
        plc_acv,

        bp_acv,
        eam_acv,
        fin_acv,
        gab_acv,
        plc_acv,
        pro_acv,
        other_acv

    from base

    union all

    select
        opportunity_id,
        opportunity_name,
        stage_name,
        current_acv,

        'pro',
        is_pro,
        pro_acv,

        bp_acv,
        eam_acv,
        fin_acv,
        gab_acv,
        plc_acv,
        pro_acv,
        other_acv

    from base

),

final as (

    select
        opportunity_id,
        opportunity_name,
        stage_name,
        current_acv,

        product as intended_product,
        is_flag,
        product_acv as quoted_acv,

        -- detect where value actually landed
        case 
            when product <> 'bp'  and coalesce(bp_acv,0)  > 0 then 'bp'
            when product <> 'eam' and coalesce(eam_acv,0) > 0 then 'eam'
            when product <> 'fin' and coalesce(fin_acv,0) > 0 then 'fin'
            when product <> 'gab' and coalesce(gab_acv,0) > 0 then 'gab'
            when product <> 'plc' and coalesce(plc_acv,0) > 0 then 'plc'
            when product <> 'pro' and coalesce(pro_acv,0) > 0 then 'pro'
            when coalesce(other_acv,0) > 0 then 'other'
            else 'none'
        end as shifted_to_product

    from unpivoted

)

select *
from final
where is_flag = 1
  and coalesce(quoted_acv,0) = 0
  and shifted_to_product <> 'none'