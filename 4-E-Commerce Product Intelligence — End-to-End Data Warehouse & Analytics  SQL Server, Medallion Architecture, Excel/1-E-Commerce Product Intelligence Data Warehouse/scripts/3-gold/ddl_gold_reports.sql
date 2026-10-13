/*
===============================================================================
DDL Script: Create Gold Report Views
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose : Pre-aggregated, analyst-friendly views built ON TOP of the star
          schema (naming convention: report_<entity>). Connect Power BI /
          Tableau directly to these for dashboards.

Run AFTER scripts/gold/ddl_gold.sql.

Views:
    gold.report_customers   one row per customer: spend, orders, recency,
                            behaviour, segment and value tier
    gold.report_products    one row per product: funnel, sales, reviews,
                            conversion rates and performance tier
    gold.report_funnel      one row per device x traffic source: the
                            session -> cart -> purchase funnel
===============================================================================
*/

-- =============================================================================
-- gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL DROP VIEW gold.report_customers;
GO
CREATE VIEW gold.report_customers AS
WITH sales AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number)  AS total_orders,
        SUM(sales_amount)             AS total_sales,
        SUM(quantity)                 AS total_quantity,
        MIN(order_date)               AS first_order_date,
        MAX(order_date)               AS last_order_date
    FROM gold.fact_sales
    GROUP BY customer_key
),
activity AS (
    SELECT
        customer_key,
        COUNT(*)                                     AS total_sessions,
        SUM(interaction_count)                       AS total_interactions,
        SUM(add_to_cart_count)                       AS total_add_to_cart
    FROM gold.fact_sessions
    GROUP BY customer_key
),
combined AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.age,
        c.age_group,
        c.gender,
        c.country,
        c.income_level,
        c.loyalty_tier,
        c.signup_date,
        ISNULL(a.total_sessions, 0)      AS total_sessions,
        ISNULL(a.total_interactions, 0)  AS total_interactions,
        ISNULL(a.total_add_to_cart, 0)   AS total_add_to_cart,
        ISNULL(s.total_orders, 0)        AS total_orders,
        ISNULL(s.total_sales, 0)         AS total_sales,
        ISNULL(s.total_quantity, 0)      AS total_quantity,
        s.first_order_date,
        s.last_order_date,
        -- recency is measured against the last order in the dataset, not GETDATE(),
        -- so the numbers stay meaningful for this historical data
        DATEDIFF(DAY, s.last_order_date, (SELECT MAX(order_date) FROM gold.fact_sales)) AS recency_days
    FROM gold.dim_customers c
    LEFT JOIN sales    s ON c.customer_key = s.customer_key
    LEFT JOIN activity a ON c.customer_key = a.customer_key
)
SELECT
    *,
    CASE WHEN total_orders = 0 THEN 0
         ELSE CAST(total_sales / total_orders AS DECIMAL(12,2)) END AS avg_order_value,
    CASE
        WHEN total_orders = 0 THEN 'Prospect'
        WHEN total_orders = 1 THEN 'One-time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_segment,
    -- value tier: quartiles of total spend, computed among BUYERS only
    CASE
        WHEN spend_quartile IS NULL THEN 'n/a'
        WHEN spend_quartile = 1     THEN 'High Value'
        WHEN spend_quartile IN (2, 3) THEN 'Mid Value'
        ELSE 'Low Value'
    END AS value_tier
FROM (
    SELECT
        *,
        CASE WHEN total_orders > 0
             THEN NTILE(4) OVER (PARTITION BY CASE WHEN total_orders > 0 THEN 1 ELSE 0 END
                                 ORDER BY total_sales DESC)
        END AS spend_quartile
    FROM combined
) t;
GO

-- =============================================================================
-- gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL DROP VIEW gold.report_products;
GO
CREATE VIEW gold.report_products AS
WITH behaviour AS (
    SELECT
        product_key,
        SUM(CASE WHEN interaction_type = 'View'            THEN 1 ELSE 0 END) AS total_views,
        SUM(CASE WHEN interaction_type = 'Add to Cart'     THEN 1 ELSE 0 END) AS total_add_to_cart,
        SUM(CASE WHEN interaction_type = 'Add to Wishlist' THEN 1 ELSE 0 END) AS total_wishlist_adds
    FROM gold.fact_interactions
    GROUP BY product_key
),
sales AS (
    SELECT
        product_key,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(quantity)                AS units_sold,
        SUM(sales_amount)            AS total_sales
    FROM gold.fact_sales
    GROUP BY product_key
),
reviews AS (
    SELECT
        product_key,
        COUNT(*)                                     AS total_reviews,
        CAST(AVG(CAST(rating AS FLOAT)) AS DECIMAL(3,2)) AS avg_review_rating,
        SUM(CASE WHEN sentiment_label = 'Negative' THEN 1 ELSE 0 END) AS negative_reviews
    FROM gold.fact_reviews
    GROUP BY product_key
),
combined AS (
    SELECT
        p.product_key, p.product_id, p.product_name, p.category, p.subcategory,
        p.brand, p.list_price, p.price_band, p.stock_quantity,
        ISNULL(b.total_views, 0)          AS total_views,
        ISNULL(b.total_add_to_cart, 0)    AS total_add_to_cart,
        ISNULL(b.total_wishlist_adds, 0)  AS total_wishlist_adds,
        ISNULL(s.total_orders, 0)         AS total_orders,
        ISNULL(s.units_sold, 0)           AS units_sold,
        ISNULL(s.total_sales, 0)          AS total_sales,
        ISNULL(r.total_reviews, 0)        AS total_reviews,
        r.avg_review_rating               AS avg_review_rating,   -- NULL = no reviews
        ISNULL(r.negative_reviews, 0)     AS negative_reviews
    FROM gold.dim_products p
    LEFT JOIN behaviour b ON p.product_key = b.product_key
    LEFT JOIN sales     s ON p.product_key = s.product_key
    LEFT JOIN reviews   r ON p.product_key = r.product_key
)
SELECT
    *,
    CAST(total_add_to_cart * 1.0 / NULLIF(total_views, 0)       AS DECIMAL(8,4)) AS view_to_cart_rate,
    CAST(total_orders      * 1.0 / NULLIF(total_add_to_cart, 0) AS DECIMAL(8,4)) AS cart_to_order_rate,
    -- performance tier: quartiles of sales, computed among products that SOLD
    CASE
        WHEN sales_quartile IS NULL THEN 'No Sales'
        WHEN sales_quartile = 1     THEN 'Top Performer'
        WHEN sales_quartile IN (2, 3) THEN 'Mid Performer'
        ELSE 'Low Performer'
    END AS performance_tier
FROM (
    SELECT
        *,
        CASE WHEN total_sales > 0
             THEN NTILE(4) OVER (PARTITION BY CASE WHEN total_sales > 0 THEN 1 ELSE 0 END
                                 ORDER BY total_sales DESC)
        END AS sales_quartile
    FROM combined
) t;
GO

-- =============================================================================
-- gold.report_funnel   (device x traffic source)
-- =============================================================================
IF OBJECT_ID('gold.report_funnel', 'V') IS NOT NULL DROP VIEW gold.report_funnel;
GO
CREATE VIEW gold.report_funnel AS
SELECT
    device_type,
    referrer_source,
    COUNT(*)                                                         AS sessions,
    SUM(CASE WHEN add_to_cart_count > 0 THEN 1 ELSE 0 END)           AS sessions_with_add_to_cart,
    SUM(CASE WHEN is_converted = 1 THEN 1 ELSE 0 END)                AS converted_sessions,
    CAST(SUM(CASE WHEN add_to_cart_count > 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS DECIMAL(8,4)) AS cart_rate,
    CAST(SUM(CASE WHEN is_converted = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)       AS DECIMAL(8,4)) AS conversion_rate,
    SUM(sales_amount)                                                AS total_sales,
    CAST(SUM(sales_amount) / COUNT(*) AS DECIMAL(12,2))              AS revenue_per_session
FROM gold.fact_sessions
GROUP BY device_type, referrer_source;
GO
