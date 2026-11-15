-- One row per customer_id (= one row per order). customer_unique_id is the real person.
CREATE OR REPLACE TABLE staging.stg_customers AS
SELECT
    customer_id,
    customer_unique_id,
    LPAD(TRIM(customer_zip_code_prefix), 5, '0') AS zip_code_prefix,
    LOWER(TRIM(customer_city))                   AS city,
    UPPER(TRIM(customer_state))                  AS state
FROM raw.customers;