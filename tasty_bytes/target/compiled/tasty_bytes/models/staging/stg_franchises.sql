select
    FRANCHISE_ID as franchise_id,
    FIRST_NAME as first_name,
    LAST_NAME as last_name,
    CITY as city,
    COUNTRY as country,
    E_MAIL as email,
    PHONE_NUMBER as phone_number
from LARSR_DB.RAW.franchise
qualify row_number() over (partition by FRANCHISE_ID order by FIRST_NAME) = 1