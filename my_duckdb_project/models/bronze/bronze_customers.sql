
SELECT
  id,
  name
FROM {{ source('ecom', 'raw_customers') }}