-- One row per product.
CREATE OR REPLACE TABLE marts.dim_product AS
SELECT -1 AS product_key, 'unknown' AS product_id, 'unknown' AS category_name,
       'unknown' AS category_name_pt, NULL::INTEGER AS photos_qty, NULL::INTEGER AS weight_g
UNION ALL
SELECT ROW_NUMBER() OVER (ORDER BY product_id),
       product_id,
       category_name,
       category_name_pt,
       photos_qty,
       weight_g
FROM staging.stg_products;