select
    COUNTRY_ID as country_id,
    COUNTRY as country_name,
    ISO_CURRENCY as iso_currency,
    ISO_COUNTRY as iso_country,
    CITY_ID as city_id,
    CITY as city_name,
    TRY_TO_NUMBER(CITY_POPULATION) as city_population
from LARSR_DB.RAW.country