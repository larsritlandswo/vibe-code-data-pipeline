
        

    
        create dynamic table LARSR_DB.DEV_LARSR_TASTY_BYTES.int_trucks_enriched
        target_lag = '1 hour'
        warehouse = LARSR_WH
        refresh_mode = AUTO

        initialize = ON_CREATE

        as (
            select
    t.truck_id,
    t.menu_type_id,
    t.primary_city,
    t.region,
    t.country,
    t.iso_country_code,
    t.franchise_flag,
    t.truck_year,
    t.make,
    t.model,
    t.ev_flag,
    t.truck_opening_date,
    f.franchise_id,
    f.first_name || ' ' || f.last_name as franchise_owner,
    f.city as franchise_city,
    f.country as franchise_country
from LARSR_DB.DEV_LARSR_TASTY_BYTES.stg_trucks t
left join LARSR_DB.DEV_LARSR_TASTY_BYTES.stg_franchises f
    on t.franchise_id = f.franchise_id
        )

    


    