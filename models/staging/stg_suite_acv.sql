{{ config(materialized='view') }}

select
    OPPORTUNITY_ID as opportunity_id,
    PRODUCT as product,
    coalesce(PRODUCT_ACV, 0) as product_acv,
    cast(CREATED_DATE as date) as created_date,
    _FIVETRAN_SYNCED as last_synced_at

from {{ source('fivetran','SUITE_ACV') }}

where PRODUCT_ACV is not null
  and PRODUCT_ACV <> 0