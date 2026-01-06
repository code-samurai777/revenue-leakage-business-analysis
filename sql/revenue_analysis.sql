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


-- =====================================================
-- AOV AND VALUE PER ORDER
-- =====================================================

-- Monthly Average Order Value (AOV)
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
  ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id), 2) AS aov
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
  ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


-- Revenue concentration: top 20% orders contribution
WITH order_revenue AS (
  SELECT
    o.order_id,
    SUM(p.payment_value) AS order_revenue
  FROM olist_orders_dataset o
  JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY o.order_id
),
ranked_orders AS (
  SELECT
    order_id,
    order_revenue,
    NTILE(5) OVER (ORDER BY order_revenue DESC) AS revenue_bucket
  FROM order_revenue
)
SELECT
  revenue_bucket,
  ROUND(SUM(order_revenue), 2) AS revenue,
  COUNT(order_id) AS orders
FROM ranked_orders
GROUP BY revenue_bucket
ORDER BY revenue_bucket;

-- NOTES:
-- Declining or flat AOV alongside rising order count indicates value leakage.
-- Revenue concentration highlights dependence on high-value orders.



