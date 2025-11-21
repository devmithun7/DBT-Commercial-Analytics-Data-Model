# DBT-Commercial-Analytics-Data-Model

```mermaid
erDiagram
    dim_customers {
        varchar customer_id PK
        varchar first_name
        varchar last_name
        varchar email
        boolean is_valid_email
        varchar phone
        varchar address
        varchar city
        varchar state
        varchar state_name
        varchar zip_code
        integer age
        varchar gender
        boolean is_vip_member
        boolean marketing_opt_in
        varchar preferred_scare_level
        integer loyalty_points
        date registration_date
        timestamp created_at
        timestamp updated_at
        varchar age_group
        varchar loyalty_tier
        varchar customer_value_segment
        varchar customer_lifecycle_stage
        varchar retention_risk_level
        varchar upsell_opportunity
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
        integer year_number
        integer month_number
        integer day_number
        boolean is_weekend
        boolean is_halloween
        integer days_to_halloween
    }

    fct_all_ticket_sales {
        varchar sale_id PK
        varchar customer_id FK
        varchar ticket_id FK
        date purchase_date
        date visit_date
        timestamp purchase_timestamp
        decimal ticket_price
        decimal discount_percent
        integer visit_hour
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
    }

    dim_customers ||--o{ fct_all_ticket_sales : has
    dim_ticket_types ||--o{ fct_all_ticket_sales : offers
    dim_dates ||--o{ fct_all_ticket_sales : relates_to
