{{ config(materialized='table', schema='gold') }}

SELECT
  o.store_id,
  o.store_name,
  COUNT(o.order_id) AS total_orders,
  SUM(o.order_total) AS total_revenue,
  AVG(o.order_total) AS avg_order_value
FROM {{ ref('silver_orders') }} o
GROUP BY o.store_id, o.store_name