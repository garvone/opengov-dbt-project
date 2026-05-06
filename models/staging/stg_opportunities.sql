{{ config(materialized='view') }}

select
    OPPORTUNITY_ID as opportunity_id,
    OPPORTUNITY_NAME as opportunity_name,

    OPPORTUNITY_TYPE as opportunity_type,
    lower(trim(STAGE_NAME)) as stage_name,
    PRODUCT as product,

    coalesce(GROSS_ACV, 0) as gross_acv,

    case when INTEREST_EAM = 'Yes' then 1 else 0 end as is_eam,
    case when INTEREST_B_P = 'Yes' then 1 else 0 end as is_bp,
    case when INTEREST_PRO = 'Yes' then 1 else 0 end as is_pro,
    case when INTEREST_FIN = 'Yes' then 1 else 0 end as is_fin,
    case when INTEREST_GAB = 'Yes' then 1 else 0 end as is_gab,
    case when INTEREST_PLC = 'Yes' then 1 else 0 end as is_plc,

    cast(CLOSE_DATE as date) as close_date,
    _FIVETRAN_SYNCED as last_synced_at

from {{ source('fivetran','OPPORTUNITIES') }}