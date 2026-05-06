{{ config(materialized='table') }}

select
    stage_name,
    intended_product || ' → ' || shifted_to_product as product_shift,
    count(distinct opportunity_id) as deal_count

from {{ ref('product_intent_shift') }}

group by
    stage_name,
    intended_product,
    shifted_to_product

order by
    stage_name,
    deal_count desc