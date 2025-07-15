SELECT
  sku,
  name,
  type,
  price,
  description
FROM {{ source('ecom', 'raw_products') }}