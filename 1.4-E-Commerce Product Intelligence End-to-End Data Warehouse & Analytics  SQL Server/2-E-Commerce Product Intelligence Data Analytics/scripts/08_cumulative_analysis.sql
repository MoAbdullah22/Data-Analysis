/*
===============================================================================
Cumulative Analysis                                          (Roadmap step 8)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Show running totals and moving averages to see whether the business is growing.

SQL Functions Used:
    - Window functions: SUM() OVER(), AVG() OVER() with a ROWS frame
===============================================================================
*/

-- Running total of sales and a 3-month moving average, month by month
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month)                                           AS running_total_sales,
    AVG(total_sales) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)  AS moving_average_3m_sales,
    avg_selling_price,
    AVG(avg_selling_price) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_average_3m_price
FROM (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
        SUM(sales_amount)                                     AS total_sales,
        AVG(unit_price)                                       AS avg_selling_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
) t
ORDER BY order_month;

-- Running total of sales per year, restarting each January
SELECT
    order_year,
    order_month,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY order_year ORDER BY order_month) AS ytd_sales
FROM (
    SELECT
        YEAR(order_date)  AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
) t
ORDER BY order_year, order_month;

-- Running total of sales by year (all years together)
SELECT
    order_year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales
FROM (
    SELECT YEAR(order_date) AS order_year, SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
) t
ORDER BY order_year;

-- Customer base growth: cumulative sign-ups
SELECT
    signup_month,
    new_customers,
    SUM(new_customers) OVER (ORDER BY signup_month) AS cumulative_customers
FROM (
    SELECT
        DATEFROMPARTS(YEAR(signup_date), MONTH(signup_date), 1) AS signup_month,
        COUNT(customer_key)                                     AS new_customers
    FROM gold.dim_customers
    GROUP BY DATEFROMPARTS(YEAR(signup_date), MONTH(signup_date), 1)
) t
ORDER BY signup_month;
