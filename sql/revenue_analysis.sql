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



-- =====================================================
-- CUSTOMER RETENTION & REPEAT BEHAVIOR
-- =====================================================

-- Orders per customer (repeat behavior)
SELECT
  orders_per_customer,
  COUNT(*) AS customer_count
FROM (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS orders_per_customer
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
) t
GROUP BY orders_per_customer
ORDER BY orders_per_customer;


-- Percentage of one-time vs repeat customers
SELECT
  CASE
    WHEN order_count = 1 THEN 'One-time'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS customers
FROM (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
) x
GROUP BY customer_type;

-- NOTES:
-- A high proportion of one-time customers indicates acquisition-driven growth.
-- Improving repeat rate typically has a stronger revenue impact than acquiring new users.



-- =====================================================
-- COHORT RETENTION ANALYSIS (MONTHLY)
-- =====================================================

WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month,
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id, DATE_TRUNC('month', o.order_purchase_timestamp)
),

cohort_activity AS (
  SELECT
    cohort_month,
    order_month,
    COUNT(DISTINCT customer_unique_id) AS active_customers
  FROM customer_orders
  GROUP BY cohort_month, order_month
),

cohort_size AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_unique_id) AS cohort_customers
  FROM customer_orders
  GROUP BY cohort_month
)

SELECT
  ca.cohort_month,
  ca.order_month,
  DATE_DIFF('month', ca.cohort_month, ca.order_month) AS month_number,
  ca.active_customers,
  cs.cohort_customers,
  ROUND(100.0 * ca.active_customers / cs.cohort_customers, 2) AS retention_rate
FROM cohort_activity ca
JOIN cohort_size cs
  ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, month_number;

-- NOTES:
-- Retention typically drops sharply after month 1 in marketplaces.
-- Improving early retention has a compounding revenue impact.
-- Later-month retention reflects true customer loyalty.



-- =====================================================
-- DELIVERY DELAYS AND CUSTOMER BEHAVIOR
-- =====================================================

-- Delivery delay in days per order
WITH delivery_delay AS (
  SELECT
    o.order_id,
    c.customer_unique_id,
    DATE_DIFF(
      'day',
      o.order_estimated_delivery_date,
      o.order_delivered_customer_date
    ) AS delay_days
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
),

customer_orders AS (
  SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY customer_unique_id
)

SELECT
  CASE
    WHEN d.delay_days <= 0 THEN 'On-time or Early'
    WHEN d.delay_days BETWEEN 1 AND 3 THEN '1–3 Days Late'
    WHEN d.delay_days BETWEEN 4 AND 7 THEN '4–7 Days Late'
    ELSE '8+ Days Late'
  END AS delivery_bucket,
  COUNT(DISTINCT d.customer_unique_id) AS customers,
  ROUND(AVG(co.total_orders), 2) AS avg_orders_per_customer
FROM delivery_delay d
JOIN customer_orders co
  ON d.customer_unique_id = co.customer_unique_id
GROUP BY delivery_bucket
ORDER BY customers DESC;

-- NOTES:
-- Customers facing longer delivery delays tend to place fewer repeat orders.
-- Delivery performance is a key driver of retention and lifetime value.



