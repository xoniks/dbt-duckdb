SELECT
  id,
  order_id,
  sku
FROM {{ source('ecom', 'raw_items') }}