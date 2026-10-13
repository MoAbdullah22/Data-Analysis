/*
===============================================================================
Funnel Report (device x traffic source)                     (Roadmap step 12)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Show the conversion funnel (session -> add to cart -> purchase) for every
      combination of device and traffic source.

Highlights:
    - cart_rate        : share of sessions with at least one add-to-cart event
    - conversion_rate  : share of sessions that ended in a purchase
    - revenue_per_session : total revenue / total sessions
===============================================================================
*/

IF OBJECT_ID('gold.report_funnel', 'V') IS NOT NULL
    DROP VIEW gold.report_funnel;
GO

CREATE VIEW gold.report_funnel AS
SELECT
    device_type,
    referrer_source,
    COUNT(*)                                                         AS total_sessions,
    SUM(CASE WHEN add_to_cart_count > 0 THEN 1 ELSE 0 END)           AS sessions_with_add_to_cart,
    SUM(CAST(is_converted AS INT))                                   AS converted_sessions,
    CAST(SUM(CASE WHEN add_to_cart_count > 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS DECIMAL(8,4)) AS cart_rate,
    CAST(SUM(CAST(is_converted AS INT)) * 1.0 / COUNT(*)             AS DECIMAL(8,4)) AS conversion_rate,
    SUM(sales_amount)                                                AS total_revenue,
    CAST(SUM(sales_amount) / COUNT(*) AS DECIMAL(12,2))              AS revenue_per_session
FROM gold.fact_sessions
GROUP BY device_type, referrer_source;
GO

-- Overall funnel (expected: 19315 -> 19315 -> 8371 -> 1440)
SELECT
    COUNT(*)                                                  AS sessions,
    SUM(CASE WHEN view_count > 0        THEN 1 ELSE 0 END)    AS sessions_with_view,
    SUM(CASE WHEN add_to_cart_count > 0 THEN 1 ELSE 0 END)    AS sessions_with_add_to_cart,
    SUM(CAST(is_converted AS INT))                            AS converted_sessions
FROM gold.fact_sessions;

-- Cart abandonment: sessions that added to cart but never bought
SELECT
    SUM(CASE WHEN add_to_cart_count > 0 THEN 1 ELSE 0 END)                         AS carts_started,
    SUM(CASE WHEN add_to_cart_count > 0 AND is_converted = 0 THEN 1 ELSE 0 END)    AS carts_abandoned,
    ROUND(100.0 * SUM(CASE WHEN add_to_cart_count > 0 AND is_converted = 0 THEN 1 ELSE 0 END)
          / NULLIF(SUM(CASE WHEN add_to_cart_count > 0 THEN 1 ELSE 0 END), 0), 2)  AS abandonment_rate_pct
FROM gold.fact_sessions;
GO
