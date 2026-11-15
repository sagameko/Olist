CREATE OR REPLACE TABLE staging.stg_sellers AS
SELECT
    seller_id,
    LPAD(TRIM(seller_zip_code_prefix), 5, '0') AS zip_code_prefix,
    LOWER(TRIM(seller_city))                   AS city,
    UPPER(TRIM(seller_state))                  AS state
FROM raw.sellers;