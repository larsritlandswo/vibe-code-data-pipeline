select
    location_id,
    placekey,
    location_name,
    city,
    region,
    iso_country_code,
    country
from {{ ref('stg_locations') }}
