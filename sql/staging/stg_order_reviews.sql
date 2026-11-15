-- Grain is (review_id, order_id): one review can cover several orders, so
-- duplicate review_ids are kept on purpose.
CREATE OR REPLACE TABLE staging.stg_order_reviews AS
SELECT
    review_id,
    order_id,
    CAST(review_score AS INTEGER)                  AS review_score,
    NULLIF(TRIM(review_comment_title), '')         AS comment_title,
    NULLIF(TRIM(review_comment_message), '')       AS comment_message,
    TRY_CAST(review_creation_date AS TIMESTAMP)    AS created_at,
    TRY_CAST(review_answer_timestamp AS TIMESTAMP) AS answered_at
FROM raw.order_reviews;