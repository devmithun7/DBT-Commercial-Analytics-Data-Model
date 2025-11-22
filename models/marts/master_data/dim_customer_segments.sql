{{ config(
    materialized = "incremental",
    unique_key = "segment_sk"
) }}

with base as (
    select
          customer_id
        , loyalty_points
        , age
        , created_at
        , updated_at
    from {{ ref('snp_customers') }}
    where dbt_valid_to is null
),

segments as (
    select
        customer_id,

        -- VALUE SEGMENT
        case
            when loyalty_points >= 10000 then 'High Value'
            when loyalty_points >= 5000  then 'Medium Value'
            else 'Low Value'
        end as customer_value_segment,

        -- LIFECYCLE STAGE
        case
            when age < 25 then 'New / Young'
            when age between 25 and 45 then 'Established'
            else 'Mature'
        end as customer_lifecycle_stage,

        -- RETENTION RISK
        case
            when loyalty_points = 0 then 'High Risk'
            when loyalty_points < 500 then 'Medium Risk'
            else 'Low Risk'
        end as retention_risk_level,

        -- UPSELL OPPORTUNITY
        case
            when loyalty_points >= 8000 then 'VIP Upgrade'
            when loyalty_points >= 3000 then 'Merchandise Bundle'
            else 'Basic Upsell'
        end as upsell_opportunity,

        created_at,
        updated_at
    from base
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as segment_sk,
        *
    from segments
)

select * from final;
