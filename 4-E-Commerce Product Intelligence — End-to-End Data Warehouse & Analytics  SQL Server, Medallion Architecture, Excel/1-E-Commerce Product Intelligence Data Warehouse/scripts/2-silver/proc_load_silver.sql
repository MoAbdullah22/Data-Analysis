/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose : ETL step that cleanses and standardises the Bronze data and loads
          the 'silver' schema (full load: truncate & insert).
===============================================================================
EXEC silver.load_silver;

*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME,
            @batch_start_time DATETIME, @batch_end_time DATETIME;
    DECLARE @rows INT;
    DECLARE @dataset_start DATETIME2(7) = '2023-01-01';

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        --------------------------------------------------------------------
        -- 1. silver.ecom_users
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.ecom_users';
        TRUNCATE TABLE silver.ecom_users;
        PRINT '>> Inserting Data Into: silver.ecom_users';
        INSERT INTO silver.ecom_users (
            user_id, age, gender, country, city,
            signup_date, income_level, preferred_category, loyalty_tier
        )
        SELECT
            TRIM(user_id),
            CASE WHEN age BETWEEN 13 AND 100 THEN age ELSE NULL END,
            CASE UPPER(TRIM(gender))
                WHEN 'FEMALE'            THEN 'Female'
                WHEN 'MALE'              THEN 'Male'
                WHEN 'NON-BINARY'        THEN 'Non-binary'
                WHEN 'PREFER NOT TO SAY' THEN 'Prefer not to say'
                ELSE 'n/a'
            END,
            CASE UPPER(TRIM(country))
                WHEN 'US' THEN 'United States' WHEN 'GB' THEN 'United Kingdom'
                WHEN 'CA' THEN 'Canada'        WHEN 'DE' THEN 'Germany'
                WHEN 'FR' THEN 'France'        WHEN 'IN' THEN 'India'
                WHEN 'AU' THEN 'Australia'     WHEN 'IT' THEN 'Italy'
                WHEN 'BR' THEN 'Brazil'        WHEN 'JP' THEN 'Japan'
                WHEN 'ES' THEN 'Spain'         WHEN 'NL' THEN 'Netherlands'
                WHEN 'CH' THEN 'Switzerland'   WHEN 'AE' THEN 'United Arab Emirates'
                WHEN 'SG' THEN 'Singapore'     WHEN 'SE' THEN 'Sweden'
                WHEN 'DK' THEN 'Denmark'       WHEN 'NO' THEN 'Norway'
                WHEN 'KR' THEN 'South Korea'   WHEN 'MX' THEN 'Mexico'
                ELSE 'n/a'
            END,
            TRIM(city),
            signup_date,
            CASE LOWER(TRIM(income_level))
                WHEN 'low'        THEN 'Low'
                WHEN 'medium'     THEN 'Medium'
                WHEN 'high'       THEN 'High'
                WHEN 'very_high'  THEN 'Very High'
                ELSE 'n/a'
            END,
            TRIM(preferred_category),
            CASE LOWER(TRIM(loyalty_tier))
                WHEN 'bronze'   THEN 'Bronze'
                WHEN 'silver'   THEN 'Silver'
                WHEN 'gold'     THEN 'Gold'
                WHEN 'platinum' THEN 'Platinum'
                ELSE 'n/a'
            END
        FROM bronze.ecom_users
        WHERE user_id IS NOT NULL;
        
        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Rows Inserted : ' + CAST(@rows AS NVARCHAR);
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        --------------------------------------------------------------------
        -- 2. silver.ecom_products
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.ecom_products';
        TRUNCATE TABLE silver.ecom_products;
        PRINT '>> Inserting Data Into: silver.ecom_products';
        INSERT INTO silver.ecom_products (
            product_id, product_name, product_description, category, subcategory,
            brand, price, rate, review_count, stock_quantity, date_added
        )
        SELECT
            TRIM(product_id),
            TRIM(product_name),
            TRIM(product_description),
            TRIM(category),
            TRIM(subcategory),
            TRIM(brand),
            CASE WHEN price > 0 THEN price ELSE NULL END,
            CASE 
                WHEN rating_avg = 1 OR rating_avg = 2 THEN 'Bad Rate'
                WHEN rating_avg = 3 THEN 'Good Rate'
                WHEN rating_avg = 4 THEN 'Very Good Rate'
                WHEN rating_avg = 5 THEN 'Excellent Rate'
                ELSE 'Not Rated'
            END, 
            CASE WHEN review_count IS NULL OR review_count < 0 THEN 0 ELSE review_count END,
            CASE WHEN stock_quantity IS NULL OR stock_quantity < 0 THEN 0 ELSE stock_quantity END,
            date_added
        FROM bronze.ecom_products
        WHERE product_id IS NOT NULL;
        
        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Rows Inserted : ' + CAST(@rows AS NVARCHAR);
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        --------------------------------------------------------------------
        -- 3. silver.ecom_sessions
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.ecom_sessions';
        TRUNCATE TABLE silver.ecom_sessions;
        PRINT '>> Inserting Data Into: silver.ecom_sessions';
        INSERT INTO silver.ecom_sessions (
            session_id, user_id, session_start, device_type, referrer_source, is_converted
        )
        SELECT
            TRIM(session_id),
            TRIM(user_id),
            TRY_CAST(LEFT(TRIM(start_time), 27) AS DATETIME2(7)),
            CASE LOWER(TRIM(device_type))
                WHEN 'mobile'  THEN 'Mobile'
                WHEN 'desktop' THEN 'Desktop'
                WHEN 'tablet'  THEN 'Tablet'
                ELSE 'n/a'
            END,
            CASE LOWER(TRIM(referrer_source))
                WHEN 'organic_search' THEN 'Organic Search'
                WHEN 'direct'         THEN 'Direct'
                WHEN 'social_media'   THEN 'Social Media'
                WHEN 'email'          THEN 'Email'
                WHEN 'paid_search'    THEN 'Paid Search'
                WHEN 'referral'       THEN 'Referral'
                WHEN 'display_ad'     THEN 'Display Ad'
                ELSE 'n/a'
            END,
            CASE WHEN UPPER(TRIM(is_converted)) IN ('TRUE', '1') THEN 1 ELSE 0 END
        FROM bronze.ecom_sessions
        WHERE session_id IS NOT NULL;
        
        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Rows Inserted : ' + CAST(@rows AS NVARCHAR);
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        --------------------------------------------------------------------
        -- 4. silver.ecom_interactions
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.ecom_interactions';
        TRUNCATE TABLE silver.ecom_interactions;
        PRINT '>> Inserting Data Into: silver.ecom_interactions';
        INSERT INTO silver.ecom_interactions (
            interaction_id, user_id, product_id, session_id,
            interaction_type, interaction_timestamp, dwell_time_ms
        )
        SELECT
            TRIM(interaction_id),
            TRIM(user_id),
            TRIM(product_id),
            TRIM(session_id),
            CASE LOWER(TRIM(interaction_type))
                WHEN 'view'                 THEN 'View'
                WHEN 'click'                THEN 'Click'
                WHEN 'add_to_cart'          THEN 'Add to Cart'
                WHEN 'add_to_wishlist'      THEN 'Add to Wishlist'
                WHEN 'remove_from_cart'     THEN 'Remove from Cart'
                WHEN 'remove_from_wishlist' THEN 'Remove from Wishlist'
                ELSE 'n/a'
            END,
            TRY_CAST(LEFT(TRIM([timestamp]), 27) AS DATETIME2(7)),
            CASE WHEN dwell_time_ms >= 0 THEN dwell_time_ms ELSE NULL END
        FROM bronze.ecom_interactions
        WHERE interaction_id IS NOT NULL;
        
        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Rows Inserted : ' + CAST(@rows AS NVARCHAR);
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        --------------------------------------------------------------------
        -- 5. silver.ecom_purchases
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.ecom_purchases';
        TRUNCATE TABLE silver.ecom_purchases;
        PRINT '>> Inserting Data Into: silver.ecom_purchases';
        INSERT INTO silver.ecom_purchases (
            purchase_id, order_id, user_id, product_id, session_id, interaction_id,
            quantity, unit_price, total_amount, order_date
        )
        SELECT
            TRIM(purchase_id),
            TRIM(order_id),
            TRIM(user_id),
            TRIM(product_id),
            TRIM(session_id),
            TRIM(interaction_id),
            quantity,
            CASE
                WHEN unit_price IS NULL OR unit_price <= 0
                    THEN total_amount / NULLIF(quantity, 0)
                ELSE unit_price
            END,
            CASE
                WHEN total_amount IS NULL OR total_amount <= 0
                     OR ABS(total_amount - quantity * unit_price) > 0.01
                    THEN quantity * unit_price
                ELSE total_amount
            END,
            TRY_CAST(LEFT(TRIM(order_date), 27) AS DATETIME2(7))
        FROM bronze.ecom_purchases
        WHERE purchase_id IS NOT NULL;
        
        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Rows Inserted : ' + CAST(@rows AS NVARCHAR);
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        --------------------------------------------------------------------
        -- 6. silver.ecom_reviews (Must run AFTER silver.ecom_purchases)
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.ecom_reviews';
        TRUNCATE TABLE silver.ecom_reviews;
        PRINT '>> Inserting Data Into: silver.ecom_reviews';
        INSERT INTO silver.ecom_reviews (
            review_id, user_id, product_id, purchase_id, rating, title, review_text,
            review_date, is_verified_purchase, is_review_date_valid
        )
        SELECT
            TRIM(r.review_id),
            TRIM(r.user_id),
            TRIM(r.product_id),
            NULLIF(TRIM(r.purchase_id), ''),
            CASE WHEN r.rating BETWEEN 1 AND 5 THEN r.rating ELSE NULL END,
            TRIM(r.title),
            TRIM(r.review_text),
            d.review_dt,
            CASE WHEN NULLIF(TRIM(r.purchase_id), '') IS NULL THEN 0 ELSE 1 END,
            CASE
                WHEN d.review_dt IS NULL                                    THEN 0
                WHEN d.review_dt < @dataset_start                           THEN 0
                WHEN p.order_date IS NOT NULL AND d.review_dt < p.order_date THEN 0
                ELSE 1
            END
        FROM bronze.ecom_reviews r
        CROSS APPLY (SELECT TRY_CAST(LEFT(TRIM(r.review_date), 27) AS DATETIME2(7)) AS review_dt) d
        LEFT JOIN silver.ecom_purchases p
               ON NULLIF(TRIM(r.purchase_id), '') = p.purchase_id
        WHERE r.review_id IS NOT NULL;

        SET @rows = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Rows Inserted : ' + CAST(@rows AS NVARCHAR);
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
        ;THROW;
    END CATCH
END
