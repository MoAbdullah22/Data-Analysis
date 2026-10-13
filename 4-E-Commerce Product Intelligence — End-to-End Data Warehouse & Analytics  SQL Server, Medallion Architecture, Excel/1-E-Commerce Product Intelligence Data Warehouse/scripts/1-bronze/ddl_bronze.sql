/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose : Creates the raw landing tables in the 'bronze' schema (dropping them
          first if they exist).

Design notes (why some columns are NVARCHAR instead of DATETIME2):
    * Source timestamps carry 9 fractional digits
      (e.g. 2023-01-16 12:57:18.000000115). SQL Server DATETIME2 supports at
      most 7, so BULK INSERT would fail. Bronze therefore keeps them as text,
      exactly as received; Silver converts them.
    * is_converted arrives as the text .
    * All text columns are NVARCHAR because city names contain Japanese,
      Korean and accented characters.
===============================================================================
*/

IF OBJECT_ID('bronze.ecom_users', 'U') IS NOT NULL DROP TABLE bronze.ecom_users;
GO
CREATE TABLE bronze.ecom_users (
    user_id             NVARCHAR(50),
    age                 INT,
    gender              NVARCHAR(50),
    country             NVARCHAR(10),
    city                NVARCHAR(100),
    signup_date         DATE,
    income_level        NVARCHAR(50),
    preferred_category  NVARCHAR(100),
    loyalty_tier        NVARCHAR(50)
);
GO
------------------------------------------------------------------
IF OBJECT_ID('bronze.ecom_products', 'U') IS NOT NULL DROP TABLE bronze.ecom_products;
GO
CREATE TABLE bronze.ecom_products (
    product_id           NVARCHAR(50),
    product_name         NVARCHAR(200),
    product_description  NVARCHAR(2000),
    category             NVARCHAR(100),
    subcategory          NVARCHAR(100),
    brand                NVARCHAR(100),
    price                DECIMAL(10,2),
    rating_avg           DECIMAL(3,1),
    review_count         INT,
    stock_quantity       INT,
    date_added           DATE
);
GO
--------------------------------------------------------------------
IF OBJECT_ID('bronze.ecom_sessions', 'U') IS NOT NULL DROP TABLE bronze.ecom_sessions;
GO
CREATE TABLE bronze.ecom_sessions (
    session_id       NVARCHAR(50),
    user_id          NVARCHAR(50),
    start_time       NVARCHAR(50),   -- raw text, 9 fractional digits
    device_type      NVARCHAR(50),
    referrer_source  NVARCHAR(50),
    is_converted     NVARCHAR(10)    -- 'True' / 'False'
);
GO
--------------------------------------------------------------------
IF OBJECT_ID('bronze.ecom_interactions', 'U') IS NOT NULL DROP TABLE bronze.ecom_interactions;
GO
CREATE TABLE bronze.ecom_interactions (
    interaction_id    NVARCHAR(50),
    user_id           NVARCHAR(50),
    product_id        NVARCHAR(50),
    session_id        NVARCHAR(50),
    interaction_type  NVARCHAR(50),
    [timestamp]       NVARCHAR(50),  -- raw text; source column name kept as-is
    dwell_time_ms     INT
);
GO
-----------------------------------------------------------------------
IF OBJECT_ID('bronze.ecom_purchases', 'U') IS NOT NULL DROP TABLE bronze.ecom_purchases;
GO
CREATE TABLE bronze.ecom_purchases (
    purchase_id     NVARCHAR(50),
    order_id        NVARCHAR(50),
    user_id         NVARCHAR(50),
    product_id      NVARCHAR(50),
    session_id      NVARCHAR(50),
    interaction_id  NVARCHAR(50),
    quantity        INT,
    unit_price      DECIMAL(10,2),
    total_amount    DECIMAL(12,2),
    order_date      NVARCHAR(50)     -- raw text, 9 fractional digits
);
GO
--------------------------------------------------------------------------------
IF OBJECT_ID('bronze.ecom_reviews', 'U') IS NOT NULL DROP TABLE bronze.ecom_reviews;
GO
CREATE TABLE bronze.ecom_reviews (
    review_id    NVARCHAR(50),
    user_id      NVARCHAR(50),
    product_id   NVARCHAR(50),
    purchase_id  NVARCHAR(50),       -- NULL = unverified review
    rating       INT,
    title        NVARCHAR(200),
    review_text  NVARCHAR(2000),
    review_date  NVARCHAR(50)
);
GO
------------------------------------------------------ Alhamdullah