{{ config(materialized='table', schema='silver') }}

SELECT
  i.id AS item_id,
  i.order_id,
  i.sku,
  p.name AS product_name,
  p.type AS product_type,
  p.price AS product_price,
  p.description AS product_description
FROM {{ ref('bronze_items') }} i
JOIN {{ ref('bronze_products') }} p
  ON i.sku = p.sku
WHERE i.id IS NOT NULL
  AND i.order_id IS NOT NULL
  AND i.sku IS NOT NULL