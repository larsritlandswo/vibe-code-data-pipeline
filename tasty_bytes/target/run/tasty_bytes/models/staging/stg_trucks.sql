
  create or replace   view LARSR_DB.PROD.stg_trucks
  
   as (
    select
    TRUCK_ID as truck_id,
    MENU_TYPE_ID as menu_type_id,
    PRIMARY_CITY as primary_city,
    REGION as region,
    ISO_REGION as iso_region,
    COUNTRY as country,
    ISO_COUNTRY_CODE as iso_country_code,
    FRANCHISE_FLAG as franchise_flag,
    YEAR as truck_year,
    MAKE as make,
    MODEL as model,
    EV_FLAG as ev_flag,
    FRANCHISE_ID as franchise_id,
    TRUCK_OPENING_DATE as truck_opening_date
from LARSR_DB.RAW.truck
  );

