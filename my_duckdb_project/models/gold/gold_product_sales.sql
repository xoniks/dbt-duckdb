{{ config(materialized='table', schema='gold') }}

SELECT
  i.sku,
  i.product_name,
  i.product_type,
  COUNT(i.item_id) AS total_items_sold,
  SUM(i.product_price) AS total_revenue
FROM {{ ref('silver_items') }} i
GROUP BY i.sku, i.product_name, i.product_type