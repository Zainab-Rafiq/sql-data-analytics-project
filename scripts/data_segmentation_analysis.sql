/*
===============================================================================
Data Segmentation Analysis
===============================================================================
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.
===============================================================================
*/

/* Segment products into cost ranges and 
 count how many products fall into each segment 
*/

WITH product_segments AS(
SELECT 
p.product_key,
p.product_name,
p.cost,
CASE
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 and 500 THEN '100-500'
	WHEN cost BETWEEN 500 and 1000 THEN '500-1000'
	ELSE 'Above 1000'
END cost_range
FROM gold.dim_products p
)
SELECT 
cost_range, 
COUNT(product_name) total_products
FROM product_segments 
GROUP BY cost_range 
ORDER BY total_products DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_spending AS (
SELECT c.customer_key,
SUM(s.sales_amount) total_spending,
MIN(s.order_date) first_order,
MAX(s.order_date) last_order,
DATEDIFF(month, MIN(s.order_date), MAX(s.order_date)) lifespan
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key 
GROUP BY c.customer_key 
)
SELECT customer_segment, 
COUNT(customer_key) total_customers
FROM(
SELECT customer_key,
total_spending,
lifespan,
CASE 
	WHEN lifespan >= 12  AND total_spending  > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending  <= 5000 THEN 'Regular'
	ELSE 'New'
END customer_segment
FROM customer_spending
) segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
