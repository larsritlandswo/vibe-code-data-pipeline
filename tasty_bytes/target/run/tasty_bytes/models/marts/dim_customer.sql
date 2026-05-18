
  
    

        create or replace transient table LARSR_DB.DEV_LARSR_TASTY_BYTES.dim_customer
         as
        (select
    customer_id,
    first_name,
    last_name,
    city,
    country,
    postal_code,
    preferred_language,
    gender,
    favourite_brand,
    marital_status,
    children_count,
    sign_up_date,
    birthday_date
from LARSR_DB.DEV_LARSR_TASTY_BYTES.stg_customers
        );
      
  