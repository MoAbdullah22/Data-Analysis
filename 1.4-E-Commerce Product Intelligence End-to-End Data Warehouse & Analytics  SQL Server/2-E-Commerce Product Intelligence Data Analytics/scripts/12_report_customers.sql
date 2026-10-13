/*
===============================================================================
Customer Report                                             (Roadmap step 12)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Consolidate the key customer metrics and behaviours into one view.

Highlights:
    1. Gathers essential fields: country, gender, age, income level, loyalty tier.
    2. Segments customers into VIP, Regular and One-time, and into age groups.
    3. Aggregates customer-level metrics:
       - total orders, total sales, total quantity purchased, total distinct products
       - lifespan (months between first and last order)
    4. Calculates KPIs:
       - recency (months since the last order, measured against the last order in the data)
       - average order value
       - average monthly spend

Scope:
    The report contains customers who placed at least one order (buyers).
    Customers with no orders are analysed in 10_data_segmentation.sql ('Prospect').
===============================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: retrieves core columns from the fact and the dimension
---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_id,
        c.country,
        c.gender,
        c.age,
        c.age_group,
        c.income_level,
        c.loyalty_tier
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: summarises key metrics at the customer level
---------------------------------------------------------------------------*/
    SELECT
        customer_key,
        customer_id,
        country,
        gender,
        age,
        age_group,
        income_level,
        loyalty_tier,
        COUNT(DISTINCT order_number)  AS total_orders,
        SUM(sales_amount)             AS total_sales,
        SUM(quantity)                 AS total_quantity,
        COUNT(DISTINCT product_key)   AS total_products,
        MIN(order_date)               AS first_order_date,
        MAX(order_date)               AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key, customer_id, country, gender, age, age_group, income_level, loyalty_tier
)

/*---------------------------------------------------------------------------
3) Final Query: combines the results and adds segments and KPIs
---------------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_id,
    country,
    gender,
    age,
    age_group,
    income_level,
    loyalty_tier,
    CASE
        WHEN total_orders >= 2 AND total_sales >= 200 THEN 'VIP'
        WHEN total_orders >= 2                        THEN 'Regular'
        ELSE 'One-time'
    END AS customer_segment,
    first_order_date,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, (SELECT MAX(order_date) FROM gold.fact_sales)) AS recency_in_months,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    -- Average order value (AOV)
    CAST(total_sales * 1.0 / total_orders AS DECIMAL(12,2)) AS avg_order_value,
    -- Average monthly spend (a single-month customer spends everything in that one month)
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE CAST(total_sales * 1.0 / lifespan AS DECIMAL(12,2))
    END AS avg_monthly_spend
FROM customer_aggregation;
GO
