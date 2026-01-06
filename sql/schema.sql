-- =====================================================
-- OLIST BRAZILIAN E-COMMERCE DATASET
-- Schema documentation for analysis
-- =====================================================

-- -------------------------------
-- TABLE: olist_orders_dataset
-- -------------------------------
-- order_id: unique identifier for each order
-- customer_id: links order to a customer
-- order_status: delivered, canceled, unavailable, etc.
-- order_purchase_timestamp: when order was placed (used for cohorts)
-- order_approved_at: when payment was approved
-- order_delivered_customer_date: when order reached customer (used for delay analysis)
-- order_estimated_delivery_date: promised delivery date

-- -------------------------------
-- TABLE: olist_customers_dataset
-- -------------------------------
-- customer_id: order-level customer identifier
-- customer_unique_id: unique customer across multiple orders
-- customer_city: city of customer
-- customer_state: state of customer

-- -------------------------------
-- TABLE: olist_order_items_dataset
-- -------------------------------
-- order_id: links item to order
-- order_item_id: item sequence within an order
-- product_id: purchased product
-- seller_id: seller fulfilling the order
-- shipping_limit_date: seller dispatch deadline
-- price: item price
-- freight_value: shipping cost charged

-- -------------------------------
-- TABLE: olist_order_payments_dataset
-- -------------------------------
-- order_id: links payment to order
-- payment_sequential: sequence of payment (split payments possible)
-- payment_type: credit_card, boleto, voucher, etc.
-- payment_installments: number of installments
-- payment_value: total amount paid

-- -------------------------------
-- TABLE: olist_sellers_dataset
-- -------------------------------
-- seller_id: unique seller identifier
-- seller_city: seller location
-- seller_state: seller state

