/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
WITH category_sales AS(
SELECT 
p.category,
SUM(s.sales_amount) total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key 
GROUP BY p.category 
)

SELECT
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER () * 100,2), '%') percentage
FROM category_sales
ORDER BY total_sales DESC; 

