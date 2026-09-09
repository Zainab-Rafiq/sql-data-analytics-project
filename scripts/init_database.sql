/*
=============================================================
Create Database and Schemas
=============================================================
This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
*/

USE master;

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;

USE DataWarehouseAnalytics;

-- Create Schemas

CREATE SCHEMA gold;


CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);


CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategorry nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);


CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);


TRUNCATE TABLE gold.dim_customers;


BULK INSERT gold.dim_customers
FROM '/var/opt/mssql/data/flat-files/dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


TRUNCATE TABLE gold.dim_products;


BULK INSERT gold.dim_products
FROM '/var/opt/mssql/data/flat-files/dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


TRUNCATE TABLE gold.fact_sales;


BULK INSERT gold.fact_sales
FROM '/var/opt/mssql/data/flat-files/fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
