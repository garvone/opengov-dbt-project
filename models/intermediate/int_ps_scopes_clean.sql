{{ config(materialized='table') }}

with base as (

    select
        ps_request_id,
        opportunity_id,
        submitted_date,
        last_synced_at,

        coalesce(gab_hours, 0) as gab_hours,
        coalesce(fin_hours, 0) as fin_hours,
        coalesce(eam_hours, 0) as eam_hours,
        coalesce(bn_hours, 0) as bp_hours,
        coalesce(plc_hours, 0) as plc_hours,
        coalesce(pro_hours, 0) as pro_hours

    from {{ ref('stg_ps_scopes') }}

)

select
    *

from base