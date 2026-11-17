-- One row per calendar day, generated (no source file has a list of days).
-- The range covers every date column in staging, rounded out to whole years.
CREATE OR REPLACE TABLE marts.dim_date AS
WITH all_dates AS (
    SELECT purchased_at AS ts FROM staging.stg_orders
    UNION ALL SELECT estimated_delivery_at FROM staging.stg_orders
    UNION ALL SELECT delivered_at          FROM staging.stg_orders
    UNION ALL SELECT shipping_limit_at     FROM staging.stg_order_items
),
bounds AS (
    SELECT DATE_TRUNC('year', MIN(ts))::DATE                         AS first_day,
           (DATE_TRUNC('year', MAX(ts)) + INTERVAL 1 YEAR - INTERVAL 1 DAY)::DATE AS last_day
    FROM all_dates
),
days AS (
    SELECT CAST(d AS DATE) AS full_date
    FROM bounds, generate_series(first_day, last_day, INTERVAL 1 DAY) AS t(d)
)
SELECT -1 AS date_key, NULL::DATE AS full_date, NULL::INTEGER AS year,
       NULL::INTEGER AS quarter, NULL::INTEGER AS month, 'Unknown' AS month_name,
       'Unknown' AS day_name, NULL::BOOLEAN AS is_weekend
UNION ALL
SELECT CAST(strftime(full_date, '%Y%m%d') AS INTEGER),
       full_date,
       year(full_date),
       quarter(full_date),
       month(full_date),
       monthname(full_date),
       dayname(full_date),
       isodow(full_date) IN (6, 7)
FROM days;