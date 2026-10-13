/*
===============================================================================
Measures Exploration (Key Metrics)                           (Roadmap step 4)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Calculate the big numbers of the business in one place.
    - Check totals against the dataset documentation.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Total sales (revenue)
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;

-- How many items were sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;

-- Average selling price (price actually paid) vs average list price
SELECT
    AVG(unit_price) AS avg_selling_price,
    AVG(list_price) AS avg_list_price
FROM gold.fact_sales;

-- Total number of orders (lines vs distinct orders)
SELECT COUNT(order_number)          AS order_lines  FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales;

-- Average order value
SELECT SUM(sales_amount) / COUNT(DISTINCT order_number) AS avg_order_value FROM gold.fact_sales;

-- Total number of products
SELECT COUNT(product_key) AS total_products FROM gold.dim_products;

-- Total number of customers, and how many have placed an order
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;
SELECT COUNT(DISTINCT customer_key) AS customers_with_orders FROM gold.fact_sales;

-- Total sessions and the conversion rate
SELECT
    COUNT(*)                                                        AS total_sessions,
    SUM(CAST(is_converted AS INT))                                  AS converted_sessions,
    ROUND(100.0 * SUM(CAST(is_converted AS INT)) / COUNT(*), 2)     AS conversion_rate_pct
FROM gold.fact_sessions;

-- Total reviews and the average rating
SELECT
    COUNT(*)                     AS total_reviews,
    ROUND(AVG(CAST(rating AS FLOAT)), 2) AS avg_rating
FROM gold.fact_reviews;

-- Generate a report that shows all key metrics of the business
SELECT 'Total Sales'             AS measure_name, CAST(SUM(sales_amount) AS DECIMAL(14,2)) AS measure_value FROM gold.fact_sales
UNION ALL SELECT 'Total Quantity',             SUM(quantity)                                    FROM gold.fact_sales
UNION ALL SELECT 'Average Selling Price',      CAST(AVG(unit_price) AS DECIMAL(14,2))           FROM gold.fact_sales
UNION ALL SELECT 'Total Orders',               COUNT(DISTINCT order_number)                     FROM gold.fact_sales
UNION ALL SELECT 'Average Order Value',        CAST(SUM(sales_amount) / COUNT(DISTINCT order_number) AS DECIMAL(14,2)) FROM gold.fact_sales
UNION ALL SELECT 'Total Products',             COUNT(product_key)                               FROM gold.dim_products
UNION ALL SELECT 'Total Customers',            COUNT(customer_key)                              FROM gold.dim_customers
UNION ALL SELECT 'Customers With Orders',      COUNT(DISTINCT customer_key)                     FROM gold.fact_sales
UNION ALL SELECT 'Total Sessions',             COUNT(*)                                         FROM gold.fact_sessions
UNION ALL SELECT 'Conversion Rate (%)',        CAST(100.0 * SUM(CAST(is_converted AS INT)) / COUNT(*) AS DECIMAL(14,2)) FROM gold.fact_sessions
UNION ALL SELECT 'Total Interactions',         COUNT(*)                                         FROM gold.fact_interactions
UNION ALL SELECT 'Total Reviews',              COUNT(*)                                         FROM gold.fact_reviews
UNION ALL SELECT 'Average Rating',             CAST(AVG(CAST(rating AS FLOAT)) AS DECIMAL(14,2)) FROM gold.fact_reviews;
