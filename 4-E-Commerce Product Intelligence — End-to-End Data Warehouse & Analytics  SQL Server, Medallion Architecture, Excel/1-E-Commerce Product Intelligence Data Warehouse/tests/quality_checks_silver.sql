/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose : Validates consistency, standardisation and integrity of the 'silver'
          schema. Run after:  EXEC silver.load_silver;

How to read the results:
    * Checks marked "Expectation: No Results" must return ZERO rows.
    * Checks marked "Expectation: <value>" should match the value shown
      (taken from the source files).
===============================================================================
*/

-- ============================================================================
-- 1. Row-count reconciliation (Bronze -> Silver)
-- Expectation: every row has diff = 0
-- ============================================================================
SELECT 'users'        AS entity, (SELECT COUNT(*) FROM bronze.ecom_users)        AS bronze_rows, (SELECT COUNT(*) FROM silver.ecom_users)        AS silver_rows UNION ALL
SELECT 'products',               (SELECT COUNT(*) FROM bronze.ecom_products),                   (SELECT COUNT(*) FROM silver.ecom_products)        UNION ALL
SELECT 'sessions',               (SELECT COUNT(*) FROM bronze.ecom_sessions),                   (SELECT COUNT(*) FROM silver.ecom_sessions)        UNION ALL
SELECT 'interactions',           (SELECT COUNT(*) FROM bronze.ecom_interactions),               (SELECT COUNT(*) FROM silver.ecom_interactions)    UNION ALL
SELECT 'purchases',              (SELECT COUNT(*) FROM bronze.ecom_purchases),                  (SELECT COUNT(*) FROM silver.ecom_purchases)       UNION ALL
SELECT 'reviews',                (SELECT COUNT(*) FROM bronze.ecom_reviews),                    (SELECT COUNT(*) FROM silver.ecom_reviews);
-- Expected silver rows: 10000 / 1000 / 19315 / 100000 / 1737 / 1253

-- ============================================================================
-- 2. Unwanted spaces
-- Expectation: No Results
-- ============================================================================
SELECT 'users.city'          AS issue, city          FROM silver.ecom_users    WHERE city          <> TRIM(city);
SELECT 'products.name'       AS issue, product_name  FROM silver.ecom_products WHERE product_name  <> TRIM(product_name);
SELECT 'products.brand'      AS issue, brand         FROM silver.ecom_products WHERE brand         <> TRIM(brand);
SELECT 'reviews.title'       AS issue, title         FROM silver.ecom_reviews  WHERE title         <> TRIM(title);

-- ============================================================================
-- 3. Standardisation: review the distinct values by eye
-- Expectation: only the readable labels produced by silver.load_silver, no 'n/a'
-- ============================================================================
SELECT DISTINCT gender           FROM silver.ecom_users;        -- Female, Male, Non-binary, Prefer not to say
SELECT DISTINCT income_level     FROM silver.ecom_users;        -- Low, Medium, High, Very High
SELECT DISTINCT loyalty_tier     FROM silver.ecom_users;        -- Bronze, Silver, Gold, Platinum
SELECT DISTINCT country          FROM silver.ecom_users;        -- 20 countries, no 'n/a'
SELECT DISTINCT device_type      FROM silver.ecom_sessions;     -- Mobile, Desktop, Tablet
SELECT DISTINCT referrer_source  FROM silver.ecom_sessions;     -- 7 sources
SELECT DISTINCT interaction_type FROM silver.ecom_interactions; -- 6 types

-- ============================================================================
-- 4. Unconverted timestamps / dates (TRY_CAST failures become NULL)
-- Expectation: No Results
-- ============================================================================
SELECT 'sessions' AS entity, session_id FROM silver.ecom_sessions         WHERE session_start         IS NULL;
SELECT 'interactions',       interaction_id FROM silver.ecom_interactions WHERE interaction_timestamp IS NULL;
SELECT 'purchases',          purchase_id FROM silver.ecom_purchases       WHERE order_date            IS NULL;
SELECT 'reviews',            review_id FROM silver.ecom_reviews           WHERE review_date           IS NULL;

-- ============================================================================
-- 5. Business rules
-- Expectation: No Results
-- ============================================================================
SELECT * FROM silver.ecom_purchases WHERE total_amount <> quantity * unit_price;       -- total = qty * price
SELECT * FROM silver.ecom_purchases WHERE quantity <= 0 OR unit_price <= 0;            -- positive numbers
SELECT * FROM silver.ecom_reviews   WHERE rating NOT BETWEEN 1 AND 5;                  -- rating domain
SELECT * FROM silver.ecom_products  WHERE price <= 0 OR price IS NULL;                 -- valid price
SELECT * FROM silver.ecom_users     WHERE age NOT BETWEEN 13 AND 100 OR age IS NULL;   -- valid age

-- A converted session must have at least one purchase and vice-versa
SELECT s.session_id FROM silver.ecom_sessions s
WHERE s.is_converted = 1 AND NOT EXISTS (SELECT 1 FROM silver.ecom_purchases p WHERE p.session_id = s.session_id);
SELECT DISTINCT p.session_id FROM silver.ecom_purchases p
JOIN silver.ecom_sessions s ON s.session_id = p.session_id WHERE s.is_converted = 0;

-- ============================================================================
-- 6. Referential integrity (orphans)
-- Expectation: No Results
-- ============================================================================
SELECT 'sessions.user'     AS fk, session_id     FROM silver.ecom_sessions     s WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_users    u WHERE u.user_id    = s.user_id);
SELECT 'interactions.user' AS fk, interaction_id FROM silver.ecom_interactions i WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_users    u WHERE u.user_id    = i.user_id);
SELECT 'interactions.prod' AS fk, interaction_id FROM silver.ecom_interactions i WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_products p WHERE p.product_id = i.product_id);
SELECT 'interactions.sess' AS fk, interaction_id FROM silver.ecom_interactions i WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_sessions s WHERE s.session_id = i.session_id);
SELECT 'purchases.user'    AS fk, purchase_id    FROM silver.ecom_purchases    x WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_users    u WHERE u.user_id    = x.user_id);
SELECT 'purchases.prod'    AS fk, purchase_id    FROM silver.ecom_purchases    x WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_products p WHERE p.product_id = x.product_id);
SELECT 'purchases.inter'   AS fk, purchase_id    FROM silver.ecom_purchases    x WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_interactions i WHERE i.interaction_id = x.interaction_id);
SELECT 'reviews.user'      AS fk, review_id      FROM silver.ecom_reviews      r WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_users    u WHERE u.user_id    = r.user_id);
SELECT 'reviews.prod'      AS fk, review_id      FROM silver.ecom_reviews      r WHERE NOT EXISTS (SELECT 1 FROM silver.ecom_products p WHERE p.product_id = r.product_id);
SELECT 'reviews.purchase'  AS fk, review_id      FROM silver.ecom_reviews      r WHERE r.purchase_id IS NOT NULL
                                                  AND NOT EXISTS (SELECT 1 FROM silver.ecom_purchases x WHERE x.purchase_id = r.purchase_id);

-- ============================================================================
-- 7. Known data anomalies (informational, NOT failures)
-- ============================================================================
-- 43 unverified reviews are dated before the dataset starts (2023-01-01).
-- Expectation: 43 invalid, 0 of them verified.
SELECT is_verified_purchase, is_review_date_valid, COUNT(*) AS reviews
FROM silver.ecom_reviews
GROUP BY is_verified_purchase, is_review_date_valid
ORDER BY is_verified_purchase, is_review_date_valid;
-- Expected: (0,0)=43  (0,1)=157  (1,1)=1053

-- Products without any review keep NULL rating_avg (548 products)
SELECT COUNT(*) AS products_without_rating FROM silver.ecom_products WHERE rating_avg IS NULL;  -- Expectation: 548
