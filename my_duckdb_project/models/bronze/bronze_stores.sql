{{ config(materialized='table', schema='bronze') }}

SELECT
  id,
  name,
  opened_at,
  tax_rate
FROM {{ source('ecom', 'raw_stores') }}