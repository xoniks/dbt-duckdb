{{ config(materialized='table', schema='bronze') }}

SELECT
  sku,
  name,
  type,
  price,
  description
FROM {{ source('ecom', 'raw_products') }}