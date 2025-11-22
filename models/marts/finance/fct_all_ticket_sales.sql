{{ config(
    materialized = 'incremental',
    unique_key = 'sale_id'
) }}

with
    -- ============================
    -- 1. ONLINE SALES
    -- ============================
    online_sales as (
        select
              purchase_date
            , sale_id
            , payment_method
            , updated_at
            , visit_hour
            , ticket_id
            , purchase_timestamp
            , purchase_channel
            , ticket_price
            , discount_percent
            , customer_id
            , created_at
            , visit_date
            , true as is_online
        from {{ ref('stg_sales__ticket_sales_online') }}
    ),

    -- ============================
    -- 2. PHYSICAL SALES
    -- ============================
    physical_sales as (
        select
              purchase_date
            , sale_id
            , payment_method
            , updated_at
            , visit_hour
            , ticket_id
            , purchase_timestamp
            , purchase_channel
            , ticket_price
            , discount_percent
            , customer_id
            , created_at
            , visit_date
            , false as is_online
        from {{ ref('stg_sales__ticket_sales_physical') }}
    ),

    -- ============================
    -- 3. UNIONED SALES
    -- ============================
    unioned_sales as (
        select * from online_sales
        union all
        select * from physical_sales
    ),

    -- ============================
    -- 4. ENRICH BUSINESS LOGIC
    -- ============================
    enriched_sales as (
        select
              sale_id
            , customer_id
            , ticket_id
            , purchase_date
            , visit_date
            , purchase_timestamp
            , ticket_price
            , discount_percent
            , visit_hour

            -- Standardized payment method
            , case
                when payment_method = 'mobile_pay' then 'other'
                else payment_method
              end as payment_method

            , purchase_channel
            , created_at
            , updated_at
            , is_online

            -- Discount category
            , case
                when discount_percent >= 50 then 'High Discount'
                when discount_percent >= 25 then 'Medium Discount'
                when discount_percent > 0  then 'Low Discount'
                else 'No Discount'
              end as discount_category

            -- Same day vs advance visit logic
            , case when visit_date = purchase_date then true else false end as same_day_visit
            , case when visit_date > purchase_date then true else false end as advance_purchase

            -- Visit time category
            , case
                when visit_hour >= 18 then 'Evening'
                when visit_hour >= 12 then 'Afternoon'
                when visit_hour >= 6  then 'Morning'
                else 'Night'
              end as visit_time_category

        from unioned_sales
    ),

    -- ============================
    -- 5. JOIN CUSTOMER DIMENSIONS
    -- ============================
    joined_customer_profile as (
        select
              es.*
            , cp.customer_profile_sk
        from enriched_sales es
        left join {{ ref('dim_customer_profile') }} cp
            on es.customer_id = cp.customer_id
    ),

    -- ============================
    -- 6. JOIN CUSTOMER LOCATION
    -- ============================
    joined_location as (
        select
              jcp.*
            , cl.customer_location_sk
        from joined_customer_profile jcp
        left join {{ ref('dim_customer_location') }} cl
            on jcp.customer_id = cl.customer_id
    ),

    -- ============================
    -- 7. JOIN CUSTOMER SEGMENTS
    -- ============================
    joined_segments as (
        select
              jl.*
            , cs.segment_sk
        from joined_location jl
        left join {{ ref('dim_customer_segments') }} cs
            on jl.customer_id = cs.customer_id
    )

-- ============================
-- 8. FINAL OUTPUT
-- ============================
select
      sale_id
    , customer_id
    , customer_profile_sk
    , customer_location_sk
    , segment_sk
    , ticket_id

    , purchase_date
    , visit_date
    , purchase_timestamp

    , ticket_price
    , discount_percent
    , discount_category

    , visit_hour
    , visit_time_category
    , same_day_visit
    , advance_purchase

    , payment_method
    , purchase_channel
    , is_online

    , created_at
    , updated_at

from joined_segments
