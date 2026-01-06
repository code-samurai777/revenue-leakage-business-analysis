-- =====================================================
-- REVENUE ANALYSIS: BASELINE METRICS
-- =====================================================

-- Total revenue (delivered orders only)
SELECT
  ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
  ON o.order_id = p.order_id
WHERE o.order_status = 'delivered';


-- Monthly revenue trend
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
  ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
  ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


-- Order volume vs revenue
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
  ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


-- NOTES:
-- Revenue trends must be interpreted alongside order growth
-- to check whether growth is driven by volume or value (AOV).

