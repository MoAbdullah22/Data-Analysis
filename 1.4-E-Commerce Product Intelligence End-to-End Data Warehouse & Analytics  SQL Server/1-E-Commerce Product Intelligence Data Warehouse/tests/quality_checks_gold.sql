/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose : Validates the star schema: key uniqueness, fact->dimension integrity
          and reconciliation of key business totals against the source.
===============================================================================
*/

-- ============================================================================
-- 1. Surrogate keys are unique
-- Expectation: No Results
-- ============================================================================
SELECT customer_key, COUNT(*) AS n FROM gold.dim_customers GROUP BY customer_key HAVING COUNT(*) > 1;
SELECT product_key,  COUNT(*) AS n FROM gold.dim_products  GROUP BY product_key  HAVING COUNT(*) > 1;
SELECT date_key,     COUNT(*) AS n FROM gold.dim_date       GROUP BY date_key     HAVING COUNT(*) > 1;

-- ============================================================================
-- 2. Fact -> dimension integrity (a NULL key means the join failed)
-- Expectation: every count = 0
-- ============================================================================
SELECT 'fact_sales.customer_key'        AS check_name, COUNT(*) AS broken FROM gold.fact_sales        WHERE customer_key IS NULL UNION ALL
SELECT 'fact_sales.product_key',                       COUNT(*)           FROM gold.fact_sales        WHERE product_key  IS NULL UNION ALL
SELECT 'fact_interactions.customer_key',               COUNT(*)           FROM gold.fact_interactions WHERE customer_key IS NULL UNION ALL
SELECT 'fact_interactions.product_key',                COUNT(*)           FROM gold.fact_interactions WHERE product_key  IS NULL UNION ALL
SELECT 'fact_sessions.customer_key',                   COUNT(*)           FROM gold.fact_sessions     WHERE customer_key IS NULL UNION ALL
SELECT 'fact_reviews.customer_key',                    COUNT(*)           FROM gold.fact_reviews      WHERE customer_key IS NULL UNION ALL
SELECT 'fact_reviews.product_key',                     COUNT(*)           FROM gold.fact_reviews      WHERE product_key  IS NULL;

-- All fact dates exist in dim_date
SELECT 'fact_sales'        AS fact, COUNT(*) AS missing_dates FROM gold.fact_sales        f WHERE NOT EXISTS (SELECT 1 FROM gold.dim_date d WHERE d.date_key = f.order_date_key)       UNION ALL
SELECT 'fact_sessions',             COUNT(*)                  FROM gold.fact_sessions     f WHERE NOT EXISTS (SELECT 1 FROM gold.dim_date d WHERE d.date_key = f.session_date_key)     UNION ALL
SELECT 'fact_interactions',         COUNT(*)                  FROM gold.fact_interactions f WHERE NOT EXISTS (SELECT 1 FROM gold.dim_date d WHERE d.date_key = f.interaction_date_key) UNION ALL
SELECT 'fact_reviews',              COUNT(*)                  FROM gold.fact_reviews      f WHERE NOT EXISTS (SELECT 1 FROM gold.dim_date d WHERE d.date_key = f.review_date_key);

-- ============================================================================
-- 3. Reconciliation with the source dataset
-- ============================================================================
SELECT
    (SELECT COUNT(*)                   FROM gold.dim_customers)     AS customers,          -- 10000
    (SELECT COUNT(*)                   FROM gold.dim_products)      AS products,           -- 1000
    (SELECT COUNT(*)                   FROM gold.fact_sales)        AS sales_lines,        -- 1737
    (SELECT COUNT(DISTINCT order_number) FROM gold.fact_sales)      AS orders,             -- 1440
    (SELECT SUM(sales_amount)          FROM gold.fact_sales)        AS total_revenue,      -- 129510.85
    (SELECT COUNT(*)                   FROM gold.fact_sessions)     AS sessions,           -- 19315
    (SELECT SUM(CAST(is_converted AS INT)) FROM gold.fact_sessions) AS converted_sessions, -- 1440
    (SELECT COUNT(*)                   FROM gold.fact_interactions) AS interactions,       -- 100000
    (SELECT COUNT(*)                   FROM gold.fact_reviews)      AS reviews;            -- 1253

-- Revenue must be identical whether summed from sales or from sessions
SELECT
    (SELECT SUM(sales_amount) FROM gold.fact_sales)    AS revenue_from_sales,
    (SELECT SUM(sales_amount) FROM gold.fact_sessions) AS revenue_from_sessions;   -- must be equal

-- Average order value (dataset documentation: 89.94)
SELECT CAST(SUM(sales_amount) / COUNT(DISTINCT order_number) AS DECIMAL(10,2)) AS avg_order_value FROM gold.fact_sales;

-- Conversion rate (dataset documentation: 7.5%)
SELECT CAST(100.0 * SUM(CAST(is_converted AS INT)) / COUNT(*) AS DECIMAL(5,2)) AS conversion_rate_pct FROM gold.fact_sessions;
