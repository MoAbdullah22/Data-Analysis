/*
===============================================================================
Part-to-Whole Analysis                                      (Roadmap step 10)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Compare how much each category contributes to the overall total.
    - Find which categories, countries or channels drive the business.

SQL Functions Used:
    - SUM(), ROUND()
    - Window function: SUM() OVER() for the grand total
===============================================================================
*/

-- Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT p.category, SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- Which countries contribute the most to overall sales?
WITH country_sales AS (
    SELECT c.country, SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
    GROUP BY c.country
)
SELECT
    country,
    total_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM country_sales
ORDER BY total_sales DESC;

-- Share of sessions vs share of revenue by device (is revenue proportional to traffic?)
WITH device_stats AS (
    SELECT device_type, COUNT(*) AS sessions, SUM(sales_amount) AS revenue
    FROM gold.fact_sessions
    GROUP BY device_type
)
SELECT
    device_type,
    sessions,
    ROUND(100.0 * sessions / SUM(sessions) OVER (), 2) AS pct_of_sessions,
    revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2)   AS pct_of_revenue
FROM device_stats
ORDER BY sessions DESC;

-- Share of sessions vs share of revenue by traffic source
WITH source_stats AS (
    SELECT referrer_source, COUNT(*) AS sessions, SUM(sales_amount) AS revenue
    FROM gold.fact_sessions
    GROUP BY referrer_source
)
SELECT
    referrer_source,
    sessions,
    ROUND(100.0 * sessions / SUM(sessions) OVER (), 2) AS pct_of_sessions,
    revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2)   AS pct_of_revenue
FROM source_stats
ORDER BY revenue DESC;

-- Share of revenue by loyalty tier next to the tier's share of customers
WITH tier_stats AS (
    SELECT
        c.loyalty_tier,
        COUNT(DISTINCT c.customer_key) AS customers,
        ISNULL(SUM(f.sales_amount), 0) AS revenue
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f ON f.customer_key = c.customer_key
    GROUP BY c.loyalty_tier
)
SELECT
    loyalty_tier,
    customers,
    ROUND(100.0 * customers / SUM(customers) OVER (), 2) AS pct_of_customers,
    revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2)     AS pct_of_revenue
FROM tier_stats
ORDER BY revenue DESC;

-- Share of revenue by price band
WITH band_stats AS (
    SELECT p.price_band, SUM(f.sales_amount) AS revenue, SUM(f.quantity) AS units
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY p.price_band
)
SELECT
    price_band,
    units,
    revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_revenue
FROM band_stats
ORDER BY revenue DESC;

-- Share of each interaction type in all behaviour events
SELECT
    interaction_type,
    COUNT(*) AS events,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_events
FROM gold.fact_interactions
GROUP BY interaction_type
ORDER BY events DESC;
