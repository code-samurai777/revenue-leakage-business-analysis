-- Row counts
SELECT 'orders', COUNT(*) FROM olist_orders_dataset
UNION ALL
SELECT 'customers', COUNT(*) FROM olist_customers_dataset
UNION ALL
SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'payments', COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'sellers', COUNT(*) FROM olist_sellers_dataset;

-- Order status distribution
SELECT order_status, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_status;

-- Missing timestamps
SELECT
  SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END),
  SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END)
FROM olist_orders_dataset;

-- Duplicate orders
SELECT order_id, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Customers vs unique customers
SELECT
  COUNT(DISTINCT customer_id),
  COUNT(DISTINCT customer_unique_id)
FROM olist_customers_dataset;

-- Orders without items
SELECT COUNT(*)
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset i
ON o.order_id = i.order_id
WHERE i.order_id IS NULL;

-- Orders with multiple payments
SELECT order_id, COUNT(*)
FROM olist_order_payments_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Invalid payment values
SELECT COUNT(*)
FROM olist_order_payments_dataset
WHERE payment_value <= 0;


-- SUMMARY:
-- Canceled and unavailable orders must be excluded from revenue.
-- Some orders have multiple payments and must be aggregated at order level.
-- Orders without delivery dates cannot be used for delivery delay analysis.
