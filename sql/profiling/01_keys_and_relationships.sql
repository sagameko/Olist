-- 1. Is each candidate key really unique? (rows should equal distinct_keys)
SELECT 'orders.order_id' AS candidate_key,
       COUNT(*) AS rows, COUNT(DISTINCT order_id) AS distinct_keys
FROM raw_orders
UNION ALL
SELECT 'customers.customer_id', COUNT(*), COUNT(DISTINCT customer_id) FROM raw_customers
UNION ALL
SELECT 'customers.customer_unique_id', COUNT(*), COUNT(DISTINCT customer_unique_id) FROM raw_customers
UNION ALL
SELECT 'products.product_id', COUNT(*), COUNT(DISTINCT product_id) FROM raw_products
UNION ALL
SELECT 'sellers.seller_id', COUNT(*), COUNT(DISTINCT seller_id) FROM raw_sellers
UNION ALL
SELECT 'order_reviews.review_id', COUNT(*), COUNT(DISTINCT review_id) FROM raw_order_reviews
UNION ALL
SELECT 'geolocation.zip_code_prefix', COUNT(*), COUNT(DISTINCT geolocation_zip_code_prefix)
FROM raw_geolocation;

-- 2. How many items, payments and reviews does one order have?
SELECT 'items per order' AS measure, n AS per_order, COUNT(*) AS orders
FROM (SELECT order_id, COUNT(*) AS n FROM raw_order_items GROUP BY order_id) AS t
GROUP BY n
UNION ALL
SELECT 'payments per order', n, COUNT(*)
FROM (SELECT order_id, COUNT(*) AS n FROM raw_order_payments GROUP BY order_id) AS t
GROUP BY n
UNION ALL
SELECT 'reviews per order', n, COUNT(*)
FROM (SELECT order_id, COUNT(*) AS n FROM raw_order_reviews GROUP BY order_id) AS t
GROUP BY n
ORDER BY measure, per_order;

-- 3. Do all orders have items, payments and a review?
SELECT
    (SELECT COUNT(*) FROM raw_orders o
      WHERE NOT EXISTS (SELECT 1 FROM raw_order_items i WHERE i.order_id = o.order_id))
        AS orders_without_items,
    (SELECT COUNT(*) FROM raw_orders o
      WHERE NOT EXISTS (SELECT 1 FROM raw_order_payments p WHERE p.order_id = o.order_id))
        AS orders_without_payments,
    (SELECT COUNT(*) FROM raw_orders o
      WHERE NOT EXISTS (SELECT 1 FROM raw_order_reviews r WHERE r.order_id = o.order_id))
        AS orders_without_reviews;