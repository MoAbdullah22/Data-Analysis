/*
===============================================================================
Product Report                                              (Roadmap step 12)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Consolidate the key product metrics and behaviours into one view.

Highlights:
    1. Gathers essential fields: name, category, subcategory, brand, list price.
    2. Segments products by revenue into High-Performer, Mid-Range, Low-Performer
       (or 'No Sales' when the product never sold).
    3. Aggregates product-level metrics:
       - total orders, total sales, total quantity sold, total distinct customers
       - lifespan (months between first and last sale)
       - views and add-to-cart events (from the behaviour data)
       - review count and average review rating
    4. Calculates KPIs:
       - recency (months since the last sale)
       - average order revenue, average monthly revenue
       - view-to-cart rate, cart-to-order rate

Segment thresholds (based on the revenue distribution of the 427 products that sold:
    median about 92, 75th percentile about 219, 90th percentile about 620):
       High-Performer : total sales >= 500
       Mid-Range      : total sales >= 100
       Low-Performer  : total sales  > 0 and < 100

Scope:
    ALL products appear, including the ones that never sold ('No Sales').
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: every product, with its sales lines (if any)
---------------------------------------------------------------------------*/
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.brand,
        p.list_price,
        p.price_band,
        f.order_number,
        f.customer_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        f.unit_price
    FROM gold.dim_products p
    LEFT JOIN gold.fact_sales f
        ON f.product_key = p.product_key
),

product_aggregation AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: summarises sales metrics at the product level
---------------------------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        brand,
        list_price,
        price_band,
        COUNT(DISTINCT order_number)   AS total_orders,
        ISNULL(SUM(sales_amount), 0)   AS total_sales,
        ISNULL(SUM(quantity), 0)       AS total_quantity,
        COUNT(DISTINCT customer_key)   AS total_customers,
        MIN(order_date)                AS first_sale_date,
        MAX(order_date)                AS last_sale_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(unit_price AS FLOAT)), 2)          AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key, product_name, category, subcategory, brand, list_price, price_band
),

behaviour AS (
/*---------------------------------------------------------------------------
   Behaviour metrics (separate CTE so the sales rows are not duplicated)
---------------------------------------------------------------------------*/
    SELECT
        product_key,
        SUM(CASE WHEN interaction_type = 'View'        THEN 1 ELSE 0 END) AS total_views,
        SUM(CASE WHEN interaction_type = 'Add to Cart' THEN 1 ELSE 0 END) AS total_add_to_cart
    FROM gold.fact_interactions
    GROUP BY product_key
),

review_metrics AS (
    SELECT
        product_key,
        COUNT(*)                                    AS total_reviews,
        ROUND(AVG(CAST(rating AS FLOAT)), 2)        AS avg_review_rating
    FROM gold.fact_reviews
    GROUP BY product_key
)

/*---------------------------------------------------------------------------
3) Final Query: combines the results and adds the segment and KPIs
---------------------------------------------------------------------------*/
SELECT
    a.product_key,
    a.product_name,
    a.category,
    a.subcategory,
    a.brand,
    a.list_price,
    a.price_band,
    CASE
        WHEN a.total_sales >= 500 THEN 'High-Performer'
        WHEN a.total_sales >= 100 THEN 'Mid-Range'
        WHEN a.total_sales >  0   THEN 'Low-Performer'
        ELSE 'No Sales'
    END AS product_segment,
    a.first_sale_date,
    a.last_sale_date,
    DATEDIFF(MONTH, a.last_sale_date, (SELECT MAX(order_date) FROM gold.fact_sales)) AS recency_in_months,
    a.lifespan,
    a.total_orders,
    a.total_sales,
    a.total_quantity,
    a.total_customers,
    a.avg_selling_price,
    -- Average order revenue (AOR)
    CASE WHEN a.total_orders = 0 THEN 0
         ELSE CAST(a.total_sales * 1.0 / a.total_orders AS DECIMAL(12,2)) END AS avg_order_revenue,
    -- Average monthly revenue
    CASE
        WHEN a.total_sales = 0 THEN 0
        WHEN a.lifespan = 0    THEN a.total_sales
        ELSE CAST(a.total_sales * 1.0 / a.lifespan AS DECIMAL(12,2))
    END AS avg_monthly_revenue,
    ISNULL(b.total_views, 0)       AS total_views,
    ISNULL(b.total_add_to_cart, 0) AS total_add_to_cart,
    CAST(ISNULL(b.total_add_to_cart, 0) * 1.0 / NULLIF(b.total_views, 0)           AS DECIMAL(8,4)) AS view_to_cart_rate,
    CAST(a.total_orders * 1.0 / NULLIF(ISNULL(b.total_add_to_cart, 0), 0)          AS DECIMAL(8,4)) AS cart_to_order_rate,
    ISNULL(r.total_reviews, 0)     AS total_reviews,
    r.avg_review_rating            AS avg_review_rating      -- NULL = product has no reviews
FROM product_aggregation a
LEFT JOIN behaviour      b ON b.product_key = a.product_key
LEFT JOIN review_metrics r ON r.product_key = a.product_key;
GO
