{{ config(
    materialized = "incremental",
    unique_key = "customer_location_sk"
) }}

with source as (
    select
          customer_id
        , address
        , city
        , state
        , case
            when state = 'CA' then 'California'
            when state = 'NY' then 'New York'
            when state = 'TX' then 'Texas'
            -- add more if needed
            else initcap(state)
          end as state_name
        , zip_code
        , registration_date
        , created_at
        , updated_at
    from {{ ref('snp_customers') }}
    where dbt_valid_to is null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'zip_code']) }} as customer_location_sk,
        *
    from source
)

select * from final;
