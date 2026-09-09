/*
===============================================================================
Customer Report
===============================================================================
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;


CREATE VIEW gold.report_customers AS
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
WITH base_query AS (
SELECT
	f.order_number,
	f.product_key, 
	f.order_date, 
	f.sales_amount,
	f.quantity, 
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, '', c.last_name) customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key 
WHERE order_date IS NOT NULL
)
, customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) total_orders,
	SUM(sales_amount) total_sales,
	SUM(quantity) total_quantity,
	COUNT(DISTINCT product_key) total_products,
	MAX(order_date) last_order_date,
	DATEDIFF(month,MIN(order_date), MAX(order_date)) lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age 
)

SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 and 39 THEN '30-39'
	WHEN age BETWEEN 40 and 49 THEN '40-49'
	ELSE '50 AND Above'
END age_group,
CASE 
	WHEN lifespan >= 12 and total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 and total_sales <= 5000 THEN 'Regular'
	ELSE 'new'
END customer_segment,
last_order_date,
DATEDIFF(month, last_order_date, GETDATE()) recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Compuate average order value (AVO)
CASE
	WHEN total_sales = 0 THEN 0
	ELSE total_sales / total_orders
END avg_order_value,
-- Compuate average monthly spend
CASE 
	WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END avg_monthly_spend
FROM customer_aggregation

