-- One row per zip prefix, so joining on zip can never fan out.
-- Zips come from customers, sellers AND geolocation: a zip with no coordinates
-- still gets its city and state from the customer or seller table.
CREATE OR REPLACE TABLE marts.dim_geography AS
WITH address_zips AS (
    SELECT zip_code_prefix, city, state FROM staging.stg_customers
    UNION ALL
    SELECT zip_code_prefix, city, state FROM staging.stg_sellers
),
from_addresses AS (
    SELECT zip_code_prefix, MODE(city) AS city, MODE(state) AS state
    FROM address_zips
    GROUP BY zip_code_prefix
),
all_zips AS (
    SELECT zip_code_prefix FROM from_addresses
    UNION                                   -- UNION (not ALL) removes duplicates
    SELECT zip_code_prefix FROM staging.stg_geolocation
)
SELECT -1 AS geo_key, 'unknown' AS zip_code_prefix, 'unknown' AS city, 'unknown' AS state,
       NULL::DOUBLE AS lat, NULL::DOUBLE AS lng, FALSE AS has_coordinates
UNION ALL
SELECT ROW_NUMBER() OVER (ORDER BY z.zip_code_prefix),
       z.zip_code_prefix,
       COALESCE(g.city, a.city, 'unknown'),
       COALESCE(g.state, a.state, 'unknown'),
       g.lat,
       g.lng,
       g.zip_code_prefix IS NOT NULL
FROM all_zips z
LEFT JOIN staging.stg_geolocation g USING (zip_code_prefix)
LEFT JOIN from_addresses a          USING (zip_code_prefix);