-- ~1M rows -> one row per zip prefix, so joining on zip can never fan out.
-- Points outside Brazil's bounding box are dropped before averaging.
CREATE OR REPLACE TABLE staging.stg_geolocation AS
SELECT
    LPAD(TRIM(geolocation_zip_code_prefix), 5, '0') AS zip_code_prefix,
    AVG(CAST(geolocation_lat AS DOUBLE))            AS lat,
    AVG(CAST(geolocation_lng AS DOUBLE))            AS lng,
    MODE(LOWER(TRIM(geolocation_city)))             AS city,
    MODE(UPPER(TRIM(geolocation_state)))            AS state,
    COUNT(*)                                        AS source_rows
FROM raw.geolocation
WHERE CAST(geolocation_lat AS DOUBLE) BETWEEN -34 AND 6
  AND CAST(geolocation_lng AS DOUBLE) BETWEEN -74 AND -34
GROUP BY 1;