
/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.

    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses BULK INSERT to load CSV files.
    - Prints per-table and total load durations.
    - Reports errors and rethrows them if loading fails.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @start_time       DATETIME,
        @end_time         DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time   DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        ------------------------------------------------------------
        -- 1. Load ecom_users
        ------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.ecom_users';

        TRUNCATE TABLE bronze.ecom_users;

        PRINT '>> Inserting Data Into: bronze.ecom_users';

        BULK INSERT bronze.ecom_users
        FROM 'D:\Data anayst projects\5-E-Commerce Product Intelligence\1-E-Commerce Product Intelligence Data Warehouse\datasets\users.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------
        -- 2. Load ecom_products
        ------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.ecom_products';

        TRUNCATE TABLE bronze.ecom_products;

        PRINT '>> Inserting Data Into: bronze.ecom_products';

        BULK INSERT bronze.ecom_products
        FROM 'D:\Data anayst projects\5-E-Commerce Product Intelligence\1-E-Commerce Product Intelligence Data Warehouse\datasets\products.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------
        -- 3. Load ecom_sessions
        ------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.ecom_sessions';

        TRUNCATE TABLE bronze.ecom_sessions;

        PRINT '>> Inserting Data Into: bronze.ecom_sessions';

        BULK INSERT bronze.ecom_sessions
        FROM 'D:\Data anayst projects\5-E-Commerce Product Intelligence\1-E-Commerce Product Intelligence Data Warehouse\datasets\sessions.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------
        -- 4. Load ecom_interactions
        ------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.ecom_interactions';

        TRUNCATE TABLE bronze.ecom_interactions;

        PRINT '>> Inserting Data Into: bronze.ecom_interactions';

        BULK INSERT bronze.ecom_interactions
        FROM 'D:\Data anayst projects\5-E-Commerce Product Intelligence\1-E-Commerce Product Intelligence Data Warehouse\datasets\interactions.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------
        -- 5. Load ecom_purchases
        ------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.ecom_purchases';

        TRUNCATE TABLE bronze.ecom_purchases;

        PRINT '>> Inserting Data Into: bronze.ecom_purchases';

        BULK INSERT bronze.ecom_purchases
        FROM 'D:\Data anayst projects\5-E-Commerce Product Intelligence\1-E-Commerce Product Intelligence Data Warehouse\datasets\purchases.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------
        -- 6. Load ecom_reviews
        ------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.ecom_reviews';

        TRUNCATE TABLE bronze.ecom_reviews;

        PRINT '>> Inserting Data Into: bronze.ecom_reviews';

        BULK INSERT bronze.ecom_reviews
        FROM 'D:\Data anayst projects\5-E-Commerce Product Intelligence\1-E-Commerce Product Intelligence Data Warehouse\datasets\reviews.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> -------------';

        ------------------------------------------------------------
        -- Batch Summary
        ------------------------------------------------------------
        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT 'Total Load Duration: '
            + CAST(
                DATEDIFF(SECOND, @batch_start_time, @batch_end_time)
                AS NVARCHAR(20)
              )
            + ' seconds';
        PRINT '================================================';

    END TRY

    BEGIN CATCH

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT '================================================';

        THROW;

    END CATCH
END;
GO

/*
===============================================================================
Execute Bronze Load
===============================================================================
*/

EXEC bronze.load_bronze;
GO

/*
===============================================================================
Data Validation
===============================================================================
*/

-- Check the first 100 products
SELECT TOP 100 *
FROM bronze.ecom_products;

-- Count total products
SELECT COUNT(*) AS total_products
FROM bronze.ecom_products;

-- Inspect selected product columns
SELECT TOP 50
    product_id,
    product_name,
    price
FROM bronze.ecom_products;
