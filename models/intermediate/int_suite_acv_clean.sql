{{ config(materialized='table') }}

with base as (

    select
        opportunity_id,
        created_date,
        case
            when lower(trim(product)) in ('bp', 'b&p') then 'bp'
            when lower(trim(product)) = 'eam' then 'eam'
            when lower(trim(product)) = 'fin' then 'fin'
            when lower(trim(product)) = 'gab' then 'gab'
            when lower(trim(product)) = 'plc' then 'plc'
            when lower(trim(product)) = 'pro' then 'pro'

            when lower(trim(product)) in ('od','ub','rt','r&t','crt') then 'other'

            else 'other'
        end as product,
        product_acv
    from {{ ref('stg_suite_acv') }}
   

),

latest_date as (

    select
        opportunity_id,
        max(created_date) as created_date
    from base
    group by opportunity_id

),

agg as (

    select
        opportunity_id,
        sum(case when product = 'bp' then product_acv else 0 end) as bp_acv,
        sum(case when product = 'eam' then product_acv else 0 end) as eam_acv,
        sum(case when product = 'fin' then product_acv else 0 end) as fin_acv,
        sum(case when product = 'gab' then product_acv else 0 end) as gab_acv,
        sum(case when product = 'plc' then product_acv else 0 end) as plc_acv,
        sum(case when product = 'pro' then product_acv else 0 end) as pro_acv,
        sum(case when product = 'other' then product_acv else 0 end) as other_acv,
        sum(product_acv) as total_product_acv
    from base
    group by opportunity_id

)

select
    a.opportunity_id,
    l.created_date,
    a.bp_acv,
    a.eam_acv,
    a.fin_acv,
    a.gab_acv,
    a.plc_acv,
    a.pro_acv,
    a.other_acv,
    a.total_product_acv
from agg a
left join latest_date l
    on a.opportunity_id = l.opportunity_id