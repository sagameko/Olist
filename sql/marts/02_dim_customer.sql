-- One row per real person (customer_unique_id), NOT per customer_id:
-- Olist creates a new customer_id for every order.
-- Location is not stored here; it belongs to each order (customer_geo_key in the facts).
CREATE OR REPLACE TABLE marts.dim_customer AS
WITH per_person AS (
    SELECT c.customer_unique_id,
           MIN(o.purchased_at)::DATE   AS first_order_date,
           COUNT(*)                    AS order_count
    FROM staging.stg_customers c
    JOIN staging.stg_orders o USING (customer_id)
    GROUP BY c.customer_unique_id
)
SELECT -1 AS customer_key, 'unknown' AS customer_unique_id,
       NULL::DATE AS first_order_date, 0 AS order_count, FALSE AS is_repeat_customer
UNION ALL
SELECT ROW_NUMBER() OVER (ORDER BY customer_unique_id),
       customer_unique_id,
       first_order_date,
       order_count,
       order_count > 1
FROM per_person;