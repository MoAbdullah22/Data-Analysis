/*
=============================================================
Create Database, Gold Tables and Load the Data
=============================================================
Author  : Mohamed Abdullah Ali
Project : E-Commerce SQL Data Analytics

Script Purpose:
    Creates a stand-alone analytics database named 'EcommerceAnalytics' (dropping it
    first if it exists), creates the 'gold' schema with the 7 star-schema tables of the
    E-Commerce Data Warehouse project, and loads them from the CSV files in
    datasets/csv-files/.

    The tables have exactly the same names and columns as the gold VIEWS of the
    warehouse project, so every analysis script in this folder can also run against
    the 'EcommerceDW' database.

WARNING:
    Running this script DROPS the 'EcommerceAnalytics' database if it exists.
    All data in it is permanently deleted.

BEFORE YOU RUN:
    Change @base_path below to the folder that contains the gold.*.csv files.
    Requires SQL Server 2017+ (BULK INSERT ... FORMAT = 'CSV').
=============================================================
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EcommerceAnalytics')
BEGIN
    ALTER DATABASE EcommerceAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EcommerceAnalytics;
END;
GO

CREATE DATABASE EcommerceAnalytics;
GO

USE EcommerceAnalytics;
GO

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers (
    customer_key        INT,
    customer_id         NVARCHAR(50),
    age                 INT,
    age_group           NVARCHAR(10),
    gender              NVARCHAR(30),
    country_code        NVARCHAR(2),
    country             NVARCHAR(50),
    city                NVARCHAR(100),
    signup_date         DATE,
    income_level        NVARCHAR(20),
    preferred_category  NVARCHAR(100),
    loyalty_tier        NVARCHAR(20)
);
GO

CREATE TABLE gold.dim_products (
    product_key      INT,
    product_id       NVARCHAR(50),
    product_name     NVARCHAR(200),
    category         NVARCHAR(100),
    subcategory      NVARCHAR(100),
    brand            NVARCHAR(100),
    list_price       DECIMAL(10,2),
    price_band       NVARCHAR(20),
    avg_rating       DECIMAL(3,1),      -- NULL = product has no reviews
    review_count     INT,
    stock_quantity   INT,
    date_added       DATE
);
GO

CREATE TABLE gold.dim_date (
    date_key             INT,
    full_date            DATE,
    year                 INT,
    quarter              INT,
    month_number         INT,
    month_name           NVARCHAR(20),
    year_month           NVARCHAR(7),
    iso_week             INT,
    day_of_week_number   INT,           -- 1 = Monday
    day_name             NVARCHAR(20),
    is_weekend           INT
);
GO

CREATE TABLE gold.fact_sales (
    order_number        NVARCHAR(50),
    order_line_id       NVARCHAR(50),
    product_key         INT,
    customer_key        INT,
    session_id          NVARCHAR(50),
    order_date_key      INT,
    order_date          DATE,
    order_timestamp     DATETIME2(7),
    quantity            INT,
    unit_price          DECIMAL(10,2),
    list_price          DECIMAL(10,2),
    sales_amount        DECIMAL(12,2),
    price_variance_pct  DECIMAL(8,4)
);
GO

CREATE TABLE gold.fact_sessions (
    session_id            NVARCHAR(50),
    customer_key          INT,
    session_date_key      INT,
    session_start         DATETIME2(7),
    device_type           NVARCHAR(20),
    referrer_source       NVARCHAR(30),
    is_converted          BIT,
    interaction_count     INT,
    view_count            INT,
    click_count           INT,
    add_to_cart_count     INT,
    wishlist_add_count    INT,
    session_duration_sec  INT,
    order_count           INT,
    sales_amount          DECIMAL(12,2)
);
GO

CREATE TABLE gold.fact_interactions (
    interaction_id         NVARCHAR(50),
    customer_key           INT,
    product_key            INT,
    session_id             NVARCHAR(50),
    interaction_date_key   INT,
    interaction_timestamp  DATETIME2(7),
    interaction_type       NVARCHAR(30),
    dwell_time_ms          INT
);
GO

CREATE TABLE gold.fact_reviews (
    review_id             NVARCHAR(50),
    customer_key          INT,
    product_key           INT,
    order_line_id         NVARCHAR(50),     -- NULL = unverified review
    review_date_key       INT,
    review_date           DATETIME2(7),
    rating                INT,
    sentiment_label       NVARCHAR(10),
    word_count            INT,
    is_verified_purchase  BIT,
    is_review_date_valid  BIT
);
GO

-- -----------------------------------------------------------------------------
-- Load the CSV files (full load: truncate and insert)
-- -----------------------------------------------------------------------------
DECLARE @base_path NVARCHAR(400) = N'C:\sql\ecommerce-sql-analytics-project\datasets\csv-files\';
DECLARE @sql NVARCHAR(MAX);
DECLARE @t TABLE (name NVARCHAR(50));
INSERT INTO @t VALUES ('dim_customers'), ('dim_products'), ('dim_date'), ('fact_sales'),
                      ('fact_sessions'), ('fact_interactions'), ('fact_reviews');

DECLARE @name NVARCHAR(50);
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT name FROM @t;
OPEN c;
FETCH NEXT FROM c INTO @name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'TRUNCATE TABLE gold.' + @name + N'; '
             + N'BULK INSERT gold.' + @name
             + N' FROM ''' + @base_path + N'gold.' + @name + N'.csv'''
             + N' WITH (FORMAT = ''CSV'', FIRSTROW = 2, FIELDQUOTE = ''"'', FIELDTERMINATOR = '','','
             + N' ROWTERMINATOR = ''0x0d0a'', CODEPAGE = ''65001'', KEEPNULLS, TABLOCK);';
    PRINT '>> Loading gold.' + @name;
    EXEC sys.sp_executesql @sql;
    FETCH NEXT FROM c INTO @name;
END;
CLOSE c;
DEALLOCATE c;
GO

-- Row counts after loading (expected: 10000, 1000, 1826, 1737, 19315, 100000, 1253)
SELECT 'dim_customers' AS table_name, COUNT(*) AS row_count FROM gold.dim_customers UNION ALL
SELECT 'dim_products',     COUNT(*) FROM gold.dim_products     UNION ALL
SELECT 'dim_date',         COUNT(*) FROM gold.dim_date         UNION ALL
SELECT 'fact_sales',       COUNT(*) FROM gold.fact_sales       UNION ALL
SELECT 'fact_sessions',    COUNT(*) FROM gold.fact_sessions    UNION ALL
SELECT 'fact_interactions',COUNT(*) FROM gold.fact_interactions UNION ALL
SELECT 'fact_reviews',     COUNT(*) FROM gold.fact_reviews;
GO
