
  
    

        create or replace transient table LARSR_DB.DEV_LARSR_TASTY_BYTES.dim_truck
         as
        (select
    truck_id,
    menu_type_id,
    primary_city,
    region,
    country,
    iso_country_code,
    franchise_flag,
    truck_year,
    make,
    model,
    ev_flag,
    truck_opening_date,
    franchise_id,
    franchise_owner,
    franchise_city,
    franchise_country
from LARSR_DB.DEV_LARSR_TASTY_BYTES.int_trucks_enriched
        );
      
  