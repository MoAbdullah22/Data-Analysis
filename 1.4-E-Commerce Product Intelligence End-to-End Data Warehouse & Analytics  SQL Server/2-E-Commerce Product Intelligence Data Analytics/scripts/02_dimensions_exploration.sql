/*
===============================================================================
Dimensions Exploration                                       (Roadmap step 2)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Explore the categorical columns (dimensions) to learn what values exist.
    - Spot unexpected values (e.g. 'n/a') before analysing.

SQL Functions Used:
    - DISTINCT, COUNT(), ORDER BY
===============================================================================
*/

-- Where do the customers come from?
SELECT DISTINCT country FROM gold.dim_customers ORDER BY country;

-- Customer attributes
SELECT DISTINCT gender       FROM gold.dim_customers ORDER BY gender;
SELECT DISTINCT age_group    FROM gold.dim_customers ORDER BY age_group;
SELECT DISTINCT income_level FROM gold.dim_customers ORDER BY income_level;
SELECT DISTINCT loyalty_tier FROM gold.dim_customers ORDER BY loyalty_tier;

-- Product hierarchy: category -> subcategory
SELECT DISTINCT category, subcategory
FROM gold.dim_products
ORDER BY category, subcategory;

-- How big is each product dimension?
-- NOTE: distinct_product_names (857) < products (1000): product_name is NOT a unique key, use product_key.
SELECT
    COUNT(DISTINCT category)     AS categories,
    COUNT(DISTINCT subcategory)  AS subcategories,
    COUNT(DISTINCT brand)        AS brands,
    COUNT(DISTINCT product_name) AS distinct_product_names,
    COUNT(*)                     AS products
FROM gold.dim_products;

-- Price bands used to group products
SELECT DISTINCT price_band FROM gold.dim_products ORDER BY price_band;

-- Behaviour dimensions
SELECT DISTINCT device_type      FROM gold.fact_sessions     ORDER BY device_type;
SELECT DISTINCT referrer_source  FROM gold.fact_sessions     ORDER BY referrer_source;
SELECT DISTINCT interaction_type FROM gold.fact_interactions ORDER BY interaction_type;
SELECT DISTINCT sentiment_label  FROM gold.fact_reviews      ORDER BY sentiment_label;

-- Any value that failed standardisation upstream? (expected: no rows)
SELECT 'dim_customers.gender' AS column_name, COUNT(*) AS n_a_rows FROM gold.dim_customers WHERE gender = 'n/a'
UNION ALL SELECT 'dim_customers.country',        COUNT(*) FROM gold.dim_customers WHERE country = 'n/a'
UNION ALL SELECT 'dim_customers.income_level',   COUNT(*) FROM gold.dim_customers WHERE income_level = 'n/a'
UNION ALL SELECT 'dim_customers.loyalty_tier',   COUNT(*) FROM gold.dim_customers WHERE loyalty_tier = 'n/a'
UNION ALL SELECT 'fact_sessions.device_type',    COUNT(*) FROM gold.fact_sessions WHERE device_type = 'n/a'
UNION ALL SELECT 'fact_sessions.referrer_source',COUNT(*) FROM gold.fact_sessions WHERE referrer_source = 'n/a'
UNION ALL SELECT 'fact_interactions.type',       COUNT(*) FROM gold.fact_interactions WHERE interaction_type = 'n/a';
