/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)      (Roadmap step 9)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Measure the performance of products and categories over time.
    - Benchmark against their own average and against the previous period.

SQL Functions Used:
    - LAG(): accesses data from the previous row.
    - AVG() OVER(): average within a partition.
    - CASE: conditional logic for trend labels.

NOTE: 2026 is a partial year (Jan-May), so its "vs previous year" result is not like-for-like.
===============================================================================
*/

/* Analyse the yearly performance of products by comparing their sales
   to both the average sales of the product and the previous year's sales.
   NOTE: a product with no sales in the previous year gets 'No Previous Sales'
   (the previous-year row is simply missing, it is not a zero). */
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_key,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_key, p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_key) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_key) AS diff_avg,
    CASE
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_key) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_key) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year analysis
    LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) AS diff_py,
    CASE
        WHEN LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) IS NULL THEN 'No Previous Sales'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

/* Category level: much more stable than single products (most products sell only a few times) */
WITH yearly_category_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.category,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY YEAR(f.order_date), p.category
)
SELECT
    order_year,
    category,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY category)                       AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY category)       AS diff_avg,
    LAG(current_sales) OVER (PARTITION BY category ORDER BY order_year)   AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY category ORDER BY order_year) AS diff_py,
    ROUND(100.0 * (current_sales - LAG(current_sales) OVER (PARTITION BY category ORDER BY order_year))
          / NULLIF(LAG(current_sales) OVER (PARTITION BY category ORDER BY order_year), 0), 2) AS yoy_pct
FROM yearly_category_sales
ORDER BY category, order_year;

/* Month-over-month change of total sales */
WITH monthly_sales AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
        SUM(sales_amount) AS current_sales
    FROM gold.fact_sales
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    order_month,
    current_sales,
    LAG(current_sales) OVER (ORDER BY order_month) AS pm_sales,
    current_sales - LAG(current_sales) OVER (ORDER BY order_month) AS diff_pm,
    ROUND(100.0 * (current_sales - LAG(current_sales) OVER (ORDER BY order_month))
          / NULLIF(LAG(current_sales) OVER (ORDER BY order_month), 0), 2) AS mom_pct
FROM monthly_sales
ORDER BY order_month;
