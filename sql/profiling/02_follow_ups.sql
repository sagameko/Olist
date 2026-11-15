-- 1. What status do the orders without items have?
SELECT o.order_status, COUNT(*) AS orders
FROM raw_orders o
WHERE NOT EXISTS (SELECT 1 FROM raw_order_items i WHERE i.order_id = o.order_id)
GROUP BY o.order_status
ORDER BY orders DESC;

-- 2. One review_id attached to several orders: what does it look like?
SELECT review_id, order_id, review_score, review_creation_date
FROM raw_order_reviews
WHERE review_id IN (
    SELECT review_id FROM raw_order_reviews
    GROUP BY review_id HAVING COUNT(*) > 1
    LIMIT 3
)
ORDER BY review_id;

-- 3. Fan-out demo: revenue counted correctly vs after joining payments
SELECT
    (SELECT SUM(price) FROM raw_order_items) AS revenue_correct,
    (SELECT SUM(i.price)
       FROM raw_order_items i
       JOIN raw_order_payments p ON p.order_id = i.order_id) AS revenue_after_bad_join;