
  
    

        create or replace transient table LARSR_DB.PROD.dim_location
         as
        (select
    location_id,
    placekey,
    location_name,
    city,
    region,
    iso_country_code,
    country
from LARSR_DB.PROD.stg_locations
        );
      
  