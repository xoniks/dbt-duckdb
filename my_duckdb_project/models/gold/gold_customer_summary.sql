{{ config(materialized='table', schema='gold') }}

SELECT
  c.customer_id,
  c.customer_name,
  COUNT(o.order_id) AS total_orders,
  SUM(o.order_total) AS total_spend,
  AVG(o.order_total) AS avg_order_value
FROM {{ ref('silver_customers') }} c
JOIN {{ ref('silver_orders') }} o
  ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name