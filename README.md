# DBT-Commercial-Analytics-Data-Model


```mermaid
erDiagram

    %% ============================
    %% NEW COMBINED DIMENSION TABLE
    %% ============================

    dim_customer_profile {
        int customer_profile_sk PK
        varchar customer_id UK
        varchar first_name
        varchar last_name
        varchar email
        boolean is_valid_email
        varchar phone
        
        int age
        varchar age_group
        varchar gender
        int loyalty_points
        varchar loyalty_tier
        boolean marketing_opt_in
        boolean is_vip_member
        varchar preferred_scare_level

        timestamp created_at
        timestamp updated_at
    }

    %% ============================
    %% OTHER DIMENSIONS
    %% ============================

    dim_customer_location {
        int customer_location_sk PK
        varchar customer_id FK
        varchar address
        varchar city
        varchar state
        varchar state_name
        varchar zip_code
        date registration_date
        timestamp created_at
        timestamp updated_at
    }

    dim_customer_segments {
        int segment_sk PK
        varchar customer_id FK
        varchar customer_value_segment
        varchar customer_lifecycle_stage
        varchar retention_risk_level
        varchar upsell_opportunity
        timestamp created_at
        timestamp updated_at
    }

    dim_ticket_types {
        varchar ticket_id PK
        varchar ticket_type_name
        decimal price
        varchar description
        boolean includes_fast_pass
        boolean includes_vip_benefits
        date launch_date
        timestamp created_at
        timestamp updated_at
    }

    dim_dates {
        date date_day PK
        int year_number
        int month_number
        int day_number
        boolean is_weekend
        boolean is_halloween
        int days_to_halloween
    }

    %% ============================
    %% FACT TABLE
    %% ============================

    fct_all_ticket_sales {
        varchar sale_id PK
        varchar customer_id FK
        varchar ticket_id FK
        date purchase_date
        date visit_date
        timestamp purchase_timestamp
        decimal ticket_price
        decimal discount_percent
        int visit_hour
        varchar payment_method
        varchar purchase_channel
        timestamp created_at
        timestamp updated_at
        boolean is_online
        varchar discount_category
        boolean same_day_visit
        boolean advance_purchase
        varchar visit_time_category
        varchar business_season
        int customer_location_sk FK
        int customer_profile_sk FK
        int segment_sk FK
    }

    %% ============================
    %% RELATIONSHIPS
    %% ============================

    dim_customer_profile ||--o{ fct_all_ticket_sales : "customer_profile_sk"
    dim_customer_location ||--o{ fct_all_ticket_sales : "customer_location_sk"
    dim_customer_segments ||--o{ fct_all_ticket_sales : "segment_sk"

    dim_ticket_types ||--o{ fct_all_ticket_sales : "ticket_id"
    dim_dates ||--o{ fct_all_ticket_sales : "purchase_date"
    dim_dates ||--o{ fct_all_ticket_sales : "visit_date"
