select
    LOCATION_ID as location_id,
    PLACEKEY as placekey,
    LOCATION as location_name,
    CITY as city,
    REGION as region,
    ISO_COUNTRY_CODE as iso_country_code,
    COUNTRY as country
from LARSR_DB.RAW.location