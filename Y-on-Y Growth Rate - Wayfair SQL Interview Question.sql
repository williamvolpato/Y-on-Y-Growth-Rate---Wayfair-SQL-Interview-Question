WITH yearly_spend_cte AS (
  SELECT 
    EXTRACT(YEAR FROM transaction_date) AS transaction_year,
    product_id,
    SUM(spend) AS curr_year_spend,
    LAG(SUM(spend)) OVER (
      PARTITION BY product_id 
      ORDER BY EXTRACT(YEAR FROM transaction_date)
    ) AS prev_year_spend
  FROM user_transactions
  GROUP BY product_id, EXTRACT(YEAR FROM transaction_date)
)

SELECT 
  transaction_year AS year,
  product_id, 
  curr_year_spend, 
  prev_year_spend, 
  ROUND(
    CASE 
      WHEN prev_year_spend IS NOT NULL THEN 
        100 * (curr_year_spend - prev_year_spend) / prev_year_spend
      ELSE 
        NULL 
    END, 2
  ) AS yoy_rate
FROM yearly_spend_cte
ORDER BY product_id, year;
