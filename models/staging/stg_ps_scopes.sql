{{ config(materialized='view') }}

select
    PS_REQUEST_NUMBER        as ps_request_id,
    OPPORTUNITY_ID           as opportunity_id,

    cast(SUBMITTED_DATE as date) as submitted_date,
    _FIVETRAN_SYNCED         as last_synced_at,

    coalesce(GAB_SCOPED_HOURS, 0) as gab_hours,
    coalesce(FIN_SCOPED_HOURS, 0) as fin_hours,
    coalesce(EAM_SCOPED_HOURS, 0) as eam_hours,
    coalesce(BN_P_SCOPED_HOURS, 0) as bn_hours,
    coalesce(PLC_SCOPED_HOURS, 0) as plc_hours,
    coalesce(PRO_SCOPED_HOURS, 0) as pro_hours,

    coalesce(GAB_SCOPED_HOURS, 0)
  + coalesce(FIN_SCOPED_HOURS, 0)
  + coalesce(EAM_SCOPED_HOURS, 0)
  + coalesce(BN_P_SCOPED_HOURS, 0)
  + coalesce(PLC_SCOPED_HOURS, 0)
  + coalesce(PRO_SCOPED_HOURS, 0) as total_hours

from {{ source('fivetran','PS_SCOPES') }}