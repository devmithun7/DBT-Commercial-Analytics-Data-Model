{{ config(
    materialized = "incremental",
    unique_key = "customer_profile_sk"
) }}

with source as (
    select
          customer_id
        , first_name
        , last_name
        , email
        , phone
        , age
        , case
            when age < 18 then 'Minor'
            when age between 18 and 29 then 'Young Adult'
            when age between 30 and 44 then 'Adult'
            when age between 45 and 64 then 'Mid-Life'
            else 'Senior'
          end as age_group
        , gender
        , loyalty_points
        , case
            when loyalty_points >= 10000 then 'Platinum'
            when loyalty_points >= 5000  then 'Gold'
            when loyalty_points >= 1000  then 'Silver'
            else 'Bronze'
          end as loyalty_tier
        , marketing_opt_in
        , is_vip_member
        , preferred_scare_level
        , created_at
        , updated_at
    from {{ ref('snp_customers') }}
    where dbt_valid_to is null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_profile_sk,
        *
    from source
)

select * from final;
