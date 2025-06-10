{{ config(materialized='table', schema='bronze') }}

SELECT
  id,
  customer,
  ordered_at,
  store_id,
  subtotal,
  tax_paid,
  order_total
FROM {{ source('ecom', 'raw_orders') }}