/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
   - To measure the performance of products, customers, or regions over time.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
SELECT 
p.product_name,
YEAR(s.order_date) order_year,
SUM(s.sales_amount) current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key 
WHERE s.order_date IS NOT NULL
GROUP BY YEAR(s.order_date),
      p.product_name
)
SELECT
order_year,
product_name, 
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) diff_avg,
CASE 
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
ELSE 'Avg'
END avg_change,
    -- Year-over-Year Analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) diff_py_sales,
CASE 
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
