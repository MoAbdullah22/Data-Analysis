/*
===============================================================================
Date Range Exploration                                       (Roadmap step 3)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Find the time boundaries of each date column.
    - Understand how much history is available (and whether the last year is partial).

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- First and last order date and the total duration in months
SELECT
    MIN(order_date)                                       AS first_order_date,
    MAX(order_date)                                       AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date))     AS order_range_months
FROM gold.fact_sales;

-- Browsing activity range
SELECT
    MIN(session_start)                                    AS first_session,
    MAX(session_start)                                    AS last_session,
    DATEDIFF(MONTH, MIN(session_start), MAX(session_start)) AS session_range_months
FROM gold.fact_sessions;

-- Customer sign-up range
SELECT
    MIN(signup_date)                                      AS first_signup,
    MAX(signup_date)                                      AS last_signup,
    DATEDIFF(MONTH, MIN(signup_date), MAX(signup_date))   AS signup_range_months
FROM gold.dim_customers;

-- Youngest and oldest customer (the source stores age, not birthdate)
SELECT
    MIN(age) AS youngest_age,
    MAX(age) AS oldest_age,
    AVG(age) AS average_age
FROM gold.dim_customers;

-- Review dates: the earliest dates are NOT trustworthy (see is_review_date_valid)
SELECT
    MIN(review_date)                                                  AS first_review_any,
    MIN(CASE WHEN is_review_date_valid = 1 THEN review_date END)      AS first_review_valid,
    MAX(review_date)                                                  AS last_review,
    SUM(CASE WHEN is_review_date_valid = 0 THEN 1 ELSE 0 END)         AS reviews_with_invalid_date
FROM gold.fact_reviews;

-- How many days of data does each calendar year contain? (2026 is a partial year)
SELECT
    YEAR(order_date)               AS order_year,
    MIN(order_date)                AS first_order_in_year,
    MAX(order_date)                AS last_order_in_year,
    COUNT(DISTINCT order_date)     AS days_with_orders
FROM gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY order_year;
