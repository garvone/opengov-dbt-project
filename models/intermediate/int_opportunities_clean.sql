select
    opportunity_id,
    opportunity_name,
    opportunity_type,
    stage_name,
    case
        when upper(trim(product)) = 'BP' then 'BP'
        when upper(trim(product)) = 'EAM' then 'EAM'
        when upper(trim(product)) = 'FIN' then 'FIN'
        when upper(trim(product)) = 'GAB' then 'GAB'
        when upper(trim(product)) = 'PLC' then 'PLC'
        when upper(trim(product)) = 'PRO' then 'PRO'
        else 'OTHER'
    end as product,
    cast(gross_acv as number(38,2)) as gross_acv,
    close_date,
    is_bp,
    is_eam,
    is_fin,
    is_gab,
    is_plc,
    is_pro,
    last_synced_at
from {{ ref('stg_opportunities') }}