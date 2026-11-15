-- One row per item in an order. Money as DECIMAL, never DOUBLE.
CREATE OR REPLACE TABLE staging.stg_order_items AS
SELECT
    order_id,
    CAST(order_item_id AS INTEGER)               AS order_item_id,
    product_id,
    seller_id,
    TRY_CAST(shipping_limit_date AS TIMESTAMP)   AS shipping_limit_at,
    CAST(price AS DECIMAL(10, 2))                AS price,
    CAST(freight_value AS DECIMAL(10, 2))        AS freight_value
FROM raw.order_items;