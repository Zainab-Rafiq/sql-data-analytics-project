/*
===============================================================================
Cumulative Analysis
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time 
SELECT order_date,
t.total_sales, 
SUM(t.total_sales) OVER (ORDER BY order_date) running_total_sales,
AVG(t.avg_price) OVER (ORDER BY t.order_date) moving_avg_price
FROM(
SELECT 
DATETRUNC(year, order_date) order_date,
SUM(s.sales_amount) total_sales,
AVG(price) avg_price
FROM gold.fact_sales s
WHERE s.order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date) 
)t
