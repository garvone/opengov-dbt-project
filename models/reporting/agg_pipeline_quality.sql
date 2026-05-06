{{ config(materialized='table') }}

select
    acv_validation_flag,
    ps_quote_alignment,

    count(*) as total_opportunities,

    sum(current_acv) as pipeline_value,
    sum(total_product_acv) as proposed_pipeline,

    sum(acv_difference) as pipeline_gap,

    avg(current_acv) as avg_deal_size

from {{ ref('combined_fct_pipeline_product') }}
group by acv_validation_flag, ps_quote_alignment