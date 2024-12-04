-- 🌍 Português
-- Esta query calcula a taxa de crescimento YoY (Year-over-Year) para transações de produtos.
-- A lógica inclui:
-- 1. Extrair o ano da data de transação.
-- 2. Usar LAG() para obter os gastos do ano anterior.
-- 3. Calcular a taxa de crescimento e arredondar para 2 casas decimais.

-- 🌎 English
-- This query calculates the Year-over-Year (YoY) growth rate for product transactions.
-- The logic includes:
-- 1. Extracting the year from the transaction date.
-- 2. Using LAG() to get the previous year's spend.
-- 3. Calculating the growth rate and rounding to 2 decimal places.

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
