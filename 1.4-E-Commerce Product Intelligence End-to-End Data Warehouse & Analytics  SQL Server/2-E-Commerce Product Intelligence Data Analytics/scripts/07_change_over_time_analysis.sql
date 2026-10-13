/*
===============================================================================
Change-Over-Time Analysis (Trends)                           (Roadmap step 7)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Track how the business changes over time: [Measure] By [Date Dimension].
    - Identify trends and seasonality.

SQL Functions Used:
    - YEAR(), MONTH(), DATEFROMPARTS()
    - SUM(), COUNT(), AVG()

NOTE: the data ends on 2026-05-31, so 2026 is a PARTIAL year (5 months).
      Never compare 2026 totals directly with full years.
===============================================================================
*/

-- Yearly performance
SELECT
    YEAR(order_date)               AS order_year,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT customer_key)   AS total_customers,
    COUNT(DISTINCT order_number)   AS total_orders,
    SUM(quantity)                  AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Monthly performance (year and month as separate columns)
SELECT
    YEAR(order_date)               AS order_year,
    MONTH(order_date)              AS order_month,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT customer_key)   AS total_customers,
    SUM(quantity)                  AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- Monthly performance (a single first-of-month date, ideal for charts)
SELECT
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT customer_key)   AS total_customers,
    SUM(quantity)                  AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1);

-- Seasonality: which calendar months are strongest? (only complete years 2023-2025)
SELECT
    MONTH(order_date)              AS month_number,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT order_number)   AS total_orders
FROM gold.fact_sales
WHERE YEAR(order_date) BETWEEN 2023 AND 2025
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- Day-of-week pattern using the date dimension
SELECT
    d.day_of_week_number,
    d.day_name,
    SUM(f.sales_amount)            AS total_sales,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_date d ON d.date_key = f.order_date_key
GROUP BY d.day_of_week_number, d.day_name
ORDER BY d.day_of_week_number;

-- New customers per month (by sign-up date)
SELECT
    DATEFROMPARTS(YEAR(signup_date), MONTH(signup_date), 1) AS signup_month,
    COUNT(customer_key)            AS new_customers
FROM gold.dim_customers
GROUP BY DATEFROMPARTS(YEAR(signup_date), MONTH(signup_date), 1)
ORDER BY DATEFROMPARTS(YEAR(signup_date), MONTH(signup_date), 1);

-- Traffic and conversion rate per month
SELECT
    DATEFROMPARTS(YEAR(session_start), MONTH(session_start), 1) AS session_month,
    COUNT(*)                                                    AS total_sessions,
    SUM(CAST(is_converted AS INT))                              AS converted_sessions,
    ROUND(100.0 * SUM(CAST(is_converted AS INT)) / COUNT(*), 2) AS conversion_rate_pct
FROM gold.fact_sessions
GROUP BY DATEFROMPARTS(YEAR(session_start), MONTH(session_start), 1)
ORDER BY DATEFROMPARTS(YEAR(session_start), MONTH(session_start), 1);
