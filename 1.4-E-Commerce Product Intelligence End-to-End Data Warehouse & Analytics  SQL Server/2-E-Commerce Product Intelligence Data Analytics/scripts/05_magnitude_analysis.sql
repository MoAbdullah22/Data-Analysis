/*
===============================================================================
Magnitude Analysis                                           (Roadmap step 5)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Quantify the data: a measure broken down by a dimension  [Measure] By [Dimension].
    - Compare how big each group is.

SQL Functions Used:
    - SUM(), COUNT(), AVG(), GROUP BY, ORDER BY
===============================================================================
*/

-- Total customers by country
SELECT country, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Total customers by gender
SELECT gender, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Total customers by loyalty tier
SELECT loyalty_tier, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY loyalty_tier
ORDER BY total_customers DESC;

-- Total products by category
SELECT category, COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average list price by category
SELECT category, ROUND(AVG(list_price), 2) AS avg_list_price
FROM gold.dim_products
GROUP BY category
ORDER BY avg_list_price DESC;

-- Total revenue by category
SELECT p.category, SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Total revenue by country
SELECT c.country, SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Total revenue by loyalty tier (do loyal customers spend more in total?)
SELECT c.loyalty_tier, SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.loyalty_tier
ORDER BY total_revenue DESC;

-- Distribution of customers by number of orders placed (0 = never bought)
WITH orders_per_customer AS (
    SELECT c.customer_key, COUNT(DISTINCT f.order_number) AS orders
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f ON c.customer_key = f.customer_key
    GROUP BY c.customer_key
)
SELECT orders AS orders_placed, COUNT(*) AS customers
FROM orders_per_customer
GROUP BY orders
ORDER BY orders;

-- Distribution of items sold across countries
SELECT c.country, SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC;

-- Total sessions and revenue by device
SELECT device_type, COUNT(*) AS total_sessions, SUM(sales_amount) AS total_revenue
FROM gold.fact_sessions
GROUP BY device_type
ORDER BY total_sessions DESC;

-- Total sessions by traffic source
SELECT referrer_source, COUNT(*) AS total_sessions
FROM gold.fact_sessions
GROUP BY referrer_source
ORDER BY total_sessions DESC;

-- Total interactions by type
SELECT interaction_type, COUNT(*) AS total_interactions
FROM gold.fact_interactions
GROUP BY interaction_type
ORDER BY total_interactions DESC;

-- Average review rating and number of reviews by category
SELECT p.category, COUNT(r.review_id) AS total_reviews, ROUND(AVG(CAST(r.rating AS FLOAT)), 2) AS avg_rating
FROM gold.fact_reviews r
LEFT JOIN gold.dim_products p ON p.product_key = r.product_key
GROUP BY p.category
ORDER BY avg_rating DESC;
