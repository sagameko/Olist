-- One row per seller. Where the seller is located lives in dim_geography
-- (seller_geo_key in the facts), so the same geography table serves both roles.
CREATE OR REPLACE TABLE marts.dim_seller AS
SELECT -1 AS seller_key, 'unknown' AS seller_id
UNION ALL
SELECT ROW_NUMBER() OVER (ORDER BY seller_id), seller_id
FROM staging.stg_sellers;