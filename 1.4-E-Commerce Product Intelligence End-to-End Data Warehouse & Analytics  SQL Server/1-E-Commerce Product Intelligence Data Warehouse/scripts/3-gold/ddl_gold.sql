/*
===============================================================================
DDL Script: Create Gold Views  (Star Schema)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose : Creates the business-ready layer. Gold is a set of VIEWS over Silver
          (no load step): 3 dimension views + 4 fact views.

                       dim_date
                          |
   dim_customers --- fact_sales --- dim_products
         |   \                          |   \
         |    fact_sessions             |    fact_reviews
         |                              |
         +------- fact_interactions ----+

Notes:
    * Surrogate keys (customer_key, product_key) are generated with
      ROW_NUMBER() ordered by the business key. They are stable as long as the
      set of source ids does not change; after a reload with new ids, rebuild
      downstream models (Power BI) that cache keys.
    * date_key is an INT in yyyymmdd form and joins to gold.dim_date.
    * Data model grain:
        fact_sales        one row per purchased order line
        fact_sessions     one row per browsing session
        fact_interactions one row per behavioural event
        fact_reviews      one row per review
===============================================================================
*/

-- =============================================================================
-- Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY u.user_id) AS customer_key,   -- surrogate key
    u.user_id                              AS customer_id,
    u.age                                  AS age,
    CASE
        WHEN u.age IS NULL THEN 'n/a'
        WHEN u.age < 25    THEN '18-24'
        WHEN u.age < 35    THEN '25-34'
        WHEN u.age < 45    THEN '35-44'
        WHEN u.age < 55    THEN '45-54'
        ELSE '55+'
    END                                    AS age_group,
    u.gender                               AS gender,
    u.country_code                         AS country_code,
    u.country                              AS country,
    u.city                                 AS city,
    u.signup_date                          AS signup_date,
    u.income_level                         AS income_level,
    u.preferred_category                   AS preferred_category,
    u.loyalty_tier                         AS loyalty_tier
FROM silver.ecom_users u;
GO

-- =============================================================================
-- Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY p.category, p.subcategory, p.product_id) AS product_key, -- surrogate key
    p.product_id           AS product_id,
    p.product_name         AS product_name,
    p.product_description  AS product_description,
    p.category             AS category,
    p.subcategory          AS subcategory,
    p.brand                AS brand,
    p.price                AS list_price,
    CASE
        WHEN p.price IS NULL THEN 'n/a'
        WHEN p.price < 20    THEN 'Budget'
        WHEN p.price < 75    THEN 'Mid-Range'
        WHEN p.price < 200   THEN 'Premium'
        ELSE 'Luxury'
    END                    AS price_band,
    p.rating_avg           AS avg_rating,        -- NULL = no reviews
    p.review_count         AS review_count,
    p.stock_quantity       AS stock_quantity,
    p.date_added           AS date_added
FROM silver.ecom_products p;
GO

-- =============================================================================
-- Dimension: gold.dim_date   (calendar 2022-01-01 .. 2026-12-31)
-- Starts in 2022 on purpose: 43 unverified reviews carry 2022 dates (before the
-- dataset window) and must still resolve to a calendar row.
-- =============================================================================
IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL DROP VIEW gold.dim_date;
GO
CREATE VIEW gold.dim_date AS
WITH numbers AS (
    SELECT TOP (1826)                                   -- 5 years incl. leap year 2024
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
calendar AS (
    SELECT DATEADD(DAY, n, CAST('2022-01-01' AS DATE)) AS full_date
    FROM numbers
)
SELECT
    YEAR(full_date) * 10000 + MONTH(full_date) * 100 + DAY(full_date) AS date_key,
    full_date                                                        AS full_date,
    YEAR(full_date)                                                  AS year,
    DATEPART(QUARTER, full_date)                                     AS quarter,
    MONTH(full_date)                                                 AS month_number,
    DATENAME(MONTH, full_date)                                       AS month_name,
    CONCAT(YEAR(full_date), '-', RIGHT('0' + CAST(MONTH(full_date) AS VARCHAR(2)), 2)) AS year_month,
    DATEPART(ISO_WEEK, full_date)                                    AS iso_week,
    (DATEDIFF(DAY, '19000101', full_date) % 7) + 1                   AS day_of_week_number, -- 1 = Monday
    DATENAME(WEEKDAY, full_date)                                     AS day_name,
    CASE WHEN (DATEDIFF(DAY, '19000101', full_date) % 7) + 1 >= 6 THEN 1 ELSE 0 END AS is_weekend
FROM calendar;
GO

-- =============================================================================
-- Fact: gold.fact_sales   (grain = one purchased order line)
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
    pu.order_id                                                  AS order_number,
    pu.purchase_id                                               AS order_line_id,
    pr.product_key                                               AS product_key,
    cu.customer_key                                              AS customer_key,
    pu.session_id                                                AS session_id,
    CONVERT(INT, CONVERT(CHAR(8), CAST(pu.order_date AS DATE), 112)) AS order_date_key,
    CAST(pu.order_date AS DATE)                                  AS order_date,
    pu.order_date                                                AS order_timestamp,
    pu.quantity                                                  AS quantity,
    pu.unit_price                                                AS unit_price,      -- price actually paid
    pr.list_price                                                AS list_price,      -- catalogue price
    pu.total_amount                                              AS sales_amount,    -- quantity * unit_price
    CASE WHEN pr.list_price > 0
         THEN CAST((pu.unit_price - pr.list_price) / pr.list_price AS DECIMAL(8,4))
    END                                                          AS price_variance_pct
FROM silver.ecom_purchases pu
LEFT JOIN gold.dim_products  pr ON pu.product_id = pr.product_id
LEFT JOIN gold.dim_customers cu ON pu.user_id    = cu.customer_id;
GO

-- =============================================================================
-- Fact: gold.fact_sessions   (grain = one browsing session)
-- =============================================================================
IF OBJECT_ID('gold.fact_sessions', 'V') IS NOT NULL DROP VIEW gold.fact_sessions;
GO
CREATE VIEW gold.fact_sessions AS
SELECT
    s.session_id                                                    AS session_id,
    cu.customer_key                                                 AS customer_key,
    CONVERT(INT, CONVERT(CHAR(8), CAST(s.session_start AS DATE), 112)) AS session_date_key,
    s.session_start                                                 AS session_start,
    s.device_type                                                   AS device_type,
    s.referrer_source                                               AS referrer_source,
    s.is_converted                                                  AS is_converted,
    ISNULL(i.interaction_count, 0)                                  AS interaction_count,
    ISNULL(i.view_count, 0)                                         AS view_count,
    ISNULL(i.click_count, 0)                                        AS click_count,
    ISNULL(i.add_to_cart_count, 0)                                  AS add_to_cart_count,
    ISNULL(i.wishlist_add_count, 0)                                 AS wishlist_add_count,
    DATEDIFF(SECOND, s.session_start, i.last_interaction_ts)        AS session_duration_sec,
    ISNULL(p.order_count, 0)                                        AS order_count,
    ISNULL(p.sales_amount, 0)                                       AS sales_amount
FROM silver.ecom_sessions s
LEFT JOIN gold.dim_customers cu ON s.user_id = cu.customer_id
LEFT JOIN (
    SELECT session_id,
           COUNT(*)                                                                  AS interaction_count,
           SUM(CASE WHEN interaction_type = 'View'            THEN 1 ELSE 0 END)     AS view_count,
           SUM(CASE WHEN interaction_type = 'Click'           THEN 1 ELSE 0 END)     AS click_count,
           SUM(CASE WHEN interaction_type = 'Add to Cart'     THEN 1 ELSE 0 END)     AS add_to_cart_count,
           SUM(CASE WHEN interaction_type = 'Add to Wishlist' THEN 1 ELSE 0 END)     AS wishlist_add_count,
           MAX(interaction_timestamp)                                                AS last_interaction_ts
    FROM silver.ecom_interactions
    GROUP BY session_id
) i ON s.session_id = i.session_id
LEFT JOIN (
    SELECT session_id,
           COUNT(DISTINCT order_id) AS order_count,
           SUM(total_amount)        AS sales_amount
    FROM silver.ecom_purchases
    GROUP BY session_id
) p ON s.session_id = p.session_id;
GO

-- =============================================================================
-- Fact: gold.fact_interactions   (grain = one behavioural event)
-- =============================================================================
IF OBJECT_ID('gold.fact_interactions', 'V') IS NOT NULL DROP VIEW gold.fact_interactions;
GO
CREATE VIEW gold.fact_interactions AS
SELECT
    i.interaction_id                                                 AS interaction_id,
    cu.customer_key                                                  AS customer_key,
    pr.product_key                                                   AS product_key,
    i.session_id                                                     AS session_id,
    CONVERT(INT, CONVERT(CHAR(8), CAST(i.interaction_timestamp AS DATE), 112)) AS interaction_date_key,
    i.interaction_timestamp                                          AS interaction_timestamp,
    i.interaction_type                                               AS interaction_type,
    i.dwell_time_ms                                                  AS dwell_time_ms
FROM silver.ecom_interactions i
LEFT JOIN gold.dim_customers cu ON i.user_id    = cu.customer_id
LEFT JOIN gold.dim_products  pr ON i.product_id = pr.product_id;
GO

-- =============================================================================
-- Fact: gold.fact_reviews   (grain = one review)
-- =============================================================================
IF OBJECT_ID('gold.fact_reviews', 'V') IS NOT NULL DROP VIEW gold.fact_reviews;
GO
CREATE VIEW gold.fact_reviews AS
SELECT
    r.review_id                                                      AS review_id,
    cu.customer_key                                                  AS customer_key,
    pr.product_key                                                   AS product_key,
    r.purchase_id                                                    AS order_line_id,   -- NULL = unverified
    CONVERT(INT, CONVERT(CHAR(8), CAST(r.review_date AS DATE), 112)) AS review_date_key,
    r.review_date                                                    AS review_date,
    r.rating                                                         AS rating,
    CASE
        WHEN r.rating >= 4 THEN 'Positive'
        WHEN r.rating = 3  THEN 'Neutral'
        WHEN r.rating <= 2 THEN 'Negative'
        ELSE 'n/a'
    END                                                              AS sentiment_label,  -- rule-based, from rating
    r.title                                                          AS title,
    r.review_text                                                    AS review_text,
    CASE WHEN r.review_text IS NULL OR LTRIM(RTRIM(r.review_text)) = '' THEN 0
         ELSE LEN(r.review_text) - LEN(REPLACE(r.review_text, ' ', '')) + 1
    END                                                              AS word_count,
    r.is_verified_purchase                                           AS is_verified_purchase,
    r.is_review_date_valid                                           AS is_review_date_valid
FROM silver.ecom_reviews r
LEFT JOIN gold.dim_customers cu ON r.user_id    = cu.customer_id
LEFT JOIN gold.dim_products  pr ON r.product_id = pr.product_id;
GO
