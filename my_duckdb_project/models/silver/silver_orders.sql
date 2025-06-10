{{ config(materialized='table', schema='silver') }}

SELECT
  o.id AS order_id,
  o.customer AS customer_id,
  CAST(o.ordered_at AS TIMESTAMP) AS ordered_at,
  o.store_id,
  s.name AS store_name,
  o.subtotal AS order_subtotal,
  o.tax_paid,
  o.order_total
FROM {{ ref('bronze_orders') }} o
JOIN {{ ref('bronze_stores') }} s
  ON o.store_id = s.id
WHERE o.id IS NOT NULL
  AND o.customer IS NOT NULL
  AND o.store_id IS NOT NULL