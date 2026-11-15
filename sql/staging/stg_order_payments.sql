-- One row per payment. An order can be paid in several parts (card + voucher...).
CREATE OR REPLACE TABLE staging.stg_order_payments AS
SELECT
    order_id,
    CAST(payment_sequential AS INTEGER)    AS payment_sequential,
    LOWER(TRIM(payment_type))              AS payment_type,
    CAST(payment_installments AS INTEGER)  AS payment_installments,
    CAST(payment_value AS DECIMAL(10, 2))  AS payment_value
FROM raw.order_payments;