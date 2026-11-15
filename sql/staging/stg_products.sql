-- One row per product, with the English category name.
-- Source columns are misspelled ("lenght"); fixed here so nobody downstream sees it.
CREATE OR REPLACE TABLE staging.stg_products AS
SELECT
    p.product_id,
    COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'unknown') AS category_name_pt,
    COALESCE(t.product_category_name_english, 'unknown')          AS category_name,
    TRY_CAST(p.product_name_lenght AS INTEGER)        AS name_length,
    TRY_CAST(p.product_description_lenght AS INTEGER) AS description_length,
    TRY_CAST(p.product_photos_qty AS INTEGER)         AS photos_qty,
    TRY_CAST(p.product_weight_g AS INTEGER)           AS weight_g,
    TRY_CAST(p.product_length_cm AS INTEGER)          AS length_cm,
    TRY_CAST(p.product_height_cm AS INTEGER)          AS height_cm,
    TRY_CAST(p.product_width_cm AS INTEGER)           AS width_cm
FROM raw.products AS p
LEFT JOIN raw.category_translation AS t
    ON t.product_category_name = p.product_category_name;