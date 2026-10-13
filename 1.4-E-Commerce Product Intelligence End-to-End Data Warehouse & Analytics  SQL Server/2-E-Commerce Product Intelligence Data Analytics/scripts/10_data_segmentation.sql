/*
===============================================================================
Data Segmentation                                           (Roadmap step 11)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Group data into meaningful categories for targeted insights: [Measure] By [Measure].
    - Customer segmentation, product segmentation and buyer-rate comparison.

SQL Functions Used:
    - CASE: defines custom segments
    - GROUP BY: aggregates by segment
    - NTILE(): quartile-based segments
===============================================================================
*/

/* Segment products into list-price ranges and count how many fall in each */
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        list_price,
        CASE
            WHEN list_price < 20  THEN 'Below 20'
            WHEN list_price < 75  THEN '20-74.99'
            WHEN list_price < 200 THEN '75-199.99'
            ELSE '200 and above'
        END AS price_range
    FROM gold.dim_products
)
SELECT
    price_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY price_range
ORDER BY total_products DESC;

/* Segment customers by buying behaviour:
    - VIP      : at least 2 orders and total spending of 200 or more
    - Regular  : at least 2 orders (spending below 200)
    - One-time : exactly 1 order
   (Customers without any order are counted separately as 'Prospect'.) */
WITH customer_spending AS (
    SELECT
        c.customer_key,
        COUNT(DISTINCT f.order_number) AS total_orders,
        ISNULL(SUM(f.sales_amount), 0) AS total_spending
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f ON c.customer_key = f.customer_key
    GROUP BY c.customer_key
),
customer_segments AS (
    SELECT
        customer_key,
        total_spending,
        CASE
            WHEN total_orders = 0                              THEN 'Prospect'
            WHEN total_orders >= 2 AND total_spending >= 200   THEN 'VIP'
            WHEN total_orders >= 2                             THEN 'Regular'
            ELSE 'One-time'
        END AS customer_segment
    FROM customer_spending
)
SELECT
    customer_segment,
    COUNT(customer_key)                      AS total_customers,
    SUM(total_spending)                      AS total_revenue,
    ROUND(AVG(total_spending), 2)            AS avg_spending
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;

/* Spending quartiles among buyers: how concentrated is revenue? */
WITH buyer_spending AS (
    SELECT customer_key, SUM(sales_amount) AS total_spending
    FROM gold.fact_sales
    GROUP BY customer_key
),
quartiles AS (
    SELECT customer_key, total_spending, NTILE(4) OVER (ORDER BY total_spending DESC) AS spend_quartile
    FROM buyer_spending
)
SELECT
    spend_quartile,
    COUNT(*)                                                         AS customers,
    SUM(total_spending)                                              AS revenue,
    ROUND(100.0 * SUM(total_spending) / SUM(SUM(total_spending)) OVER (), 2) AS pct_of_revenue
FROM quartiles
GROUP BY spend_quartile
ORDER BY spend_quartile;

/* Who buys? Buyer rate and revenue by age group */
SELECT
    c.age_group,
    COUNT(DISTINCT c.customer_key)                                            AS customers,
    COUNT(DISTINCT f.customer_key)                                            AS buyers,
    ROUND(100.0 * COUNT(DISTINCT f.customer_key) / COUNT(DISTINCT c.customer_key), 2) AS buyer_rate_pct,
    ISNULL(SUM(f.sales_amount), 0)                                            AS total_revenue
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales f ON c.customer_key = f.customer_key
GROUP BY c.age_group
ORDER BY c.age_group;

/* Who buys? Buyer rate and revenue by income level */
SELECT
    c.income_level,
    COUNT(DISTINCT c.customer_key)                                            AS customers,
    COUNT(DISTINCT f.customer_key)                                            AS buyers,
    ROUND(100.0 * COUNT(DISTINCT f.customer_key) / COUNT(DISTINCT c.customer_key), 2) AS buyer_rate_pct,
    ISNULL(SUM(f.sales_amount), 0)                                            AS total_revenue
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales f ON c.customer_key = f.customer_key
GROUP BY c.income_level
ORDER BY buyer_rate_pct DESC;

/* Segment sessions by how many interactions they contain, and compare conversion.
   CAUTION: this is partly circular. A purchasing session necessarily contains an add-to-cart event
   plus the browsing before it, so longer sessions convert more by construction. Read it as a
   description of the sessions, not as proof that "more engagement causes purchases". */
SELECT
    CASE
        WHEN interaction_count <= 3  THEN '1. Light (1-3 events)'
        WHEN interaction_count <= 7  THEN '2. Medium (4-7 events)'
        ELSE                              '3. Heavy (8+ events)'
    END AS session_engagement,
    COUNT(*)                                                       AS sessions,
    SUM(CAST(is_converted AS INT))                                 AS converted_sessions,
    ROUND(100.0 * SUM(CAST(is_converted AS INT)) / COUNT(*), 2)    AS conversion_rate_pct
FROM gold.fact_sessions
GROUP BY CASE
        WHEN interaction_count <= 3  THEN '1. Light (1-3 events)'
        WHEN interaction_count <= 7  THEN '2. Medium (4-7 events)'
        ELSE                              '3. Heavy (8+ events)'
    END
ORDER BY session_engagement;
