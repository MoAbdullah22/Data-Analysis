/*
===============================================================================
Ranking Analysis                                             (Roadmap step 6)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Rank items (products, customers, categories...) by performance: Top N / Bottom N.

SQL Functions Used:
    - RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- IMPORTANT: product_name is NOT unique (1,000 products share only 857 names, 90 names are used by
-- more than one product with different prices). Always group by product_key, never by name alone.

-- Which 5 products generate the highest revenue? (simple TOP version)
SELECT TOP 5
    p.product_key,
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY total_revenue DESC;

-- Same question, complex but flexible version with a window function
SELECT *
FROM (
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY p.product_key, p.product_name, p.category
) AS ranked_products
WHERE rank_products <= 5;

-- What are the 5 worst-performing products among those that sold at least once?
SELECT TOP 5
    p.product_key,
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY total_revenue ASC;

-- How many products never sold at all?
SELECT COUNT(*) AS products_never_sold
FROM gold.dim_products p
WHERE NOT EXISTS (SELECT 1 FROM gold.fact_sales f WHERE f.product_key = p.product_key);

-- Top 5 subcategories by revenue
SELECT TOP 5
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.category, p.subcategory
ORDER BY total_revenue DESC;

-- Top 10 brands by revenue
SELECT TOP 10
    p.brand,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.brand
ORDER BY total_revenue DESC;

-- Top 5 countries by revenue
SELECT TOP 5
    c.country,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Top 10 customers by revenue
SELECT TOP 10
    c.customer_key,
    c.customer_id,
    c.country,
    c.loyalty_tier,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.customer_id, c.country, c.loyalty_tier
ORDER BY total_revenue DESC;

-- Customers with the MOST orders. DENSE_RANK keeps ties, ranks 1-2 are the top two order counts.
-- (A "bottom N" ranking is meaningless here: 1,141 of the 1,287 buyers ordered exactly once.)
SELECT *
FROM (
    SELECT
        c.customer_key,
        c.customer_id,
        c.country,
        COUNT(DISTINCT f.order_number)                                    AS total_orders,
        SUM(f.sales_amount)                                               AS total_revenue,
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT f.order_number) DESC)  AS rank_customers
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
    GROUP BY c.customer_key, c.customer_id, c.country
) AS ranked_customers
WHERE rank_customers <= 2
ORDER BY rank_customers, total_revenue DESC;

-- Most viewed products that sold the least: attention without conversion
SELECT TOP 10
    p.product_name,
    p.category,
    v.total_views,
    ISNULL(s.units_sold, 0) AS units_sold
FROM gold.dim_products p
JOIN (
    SELECT product_key, COUNT(*) AS total_views
    FROM gold.fact_interactions
    WHERE interaction_type = 'View'
    GROUP BY product_key
) v ON v.product_key = p.product_key
LEFT JOIN (
    SELECT product_key, SUM(quantity) AS units_sold
    FROM gold.fact_sales
    GROUP BY product_key
) s ON s.product_key = p.product_key
ORDER BY v.total_views DESC, units_sold ASC;
