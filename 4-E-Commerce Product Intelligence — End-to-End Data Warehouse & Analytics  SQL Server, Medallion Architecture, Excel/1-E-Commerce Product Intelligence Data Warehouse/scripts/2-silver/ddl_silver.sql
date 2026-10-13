/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose : Creates the cleansed tables in the 'silver' schema (dropping them 
          first if they exist). Same entities as Bronze, but with:
          - proper data types (DATETIME2(7), BIT)
          - PRIMARY KEY constraints
          - derived / enrichment columns
          - a technical column dwh_create_date on every table
===============================================================================
*/

IF OBJECT_ID('silver.ecom_users', 'U') IS NOT NULL DROP TABLE silver.ecom_users;
GO
CREATE TABLE silver.ecom_users (
    user_id             NVARCHAR(50)  NOT NULL PRIMARY KEY,
    age                 INT,
    gender              NVARCHAR(30),
    country             NVARCHAR(50),        
    city                NVARCHAR(100),
    signup_date         DATE,
    income_level        NVARCHAR(20),
    preferred_category  NVARCHAR(100),
    loyalty_tier        NVARCHAR(20),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.ecom_products', 'U') IS NOT NULL DROP TABLE silver.ecom_products;
GO
CREATE TABLE silver.ecom_products (
    product_id           NVARCHAR(50)  NOT NULL PRIMARY KEY,
    product_name         NVARCHAR(200),
    product_description  NVARCHAR(2000),
    category             NVARCHAR(100),
    subcategory          NVARCHAR(100),
    brand                NVARCHAR(100),
    price                DECIMAL(10,2),
    rate                 NVARCHAR(50),       -- NULL = product has no reviews
    review_count         INT,
    stock_quantity       INT,
    date_added           DATE,
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.ecom_sessions', 'U') IS NOT NULL DROP TABLE silver.ecom_sessions;
GO
CREATE TABLE silver.ecom_sessions (
    session_id       NVARCHAR(50)  NOT NULL PRIMARY KEY,
    user_id          NVARCHAR(50),
    session_start    DATETIME2(7),
    device_type      NVARCHAR(20),
    referrer_source  NVARCHAR(30),
    is_converted     BIT,
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.ecom_interactions', 'U') IS NOT NULL DROP TABLE silver.ecom_interactions;
GO
CREATE TABLE silver.ecom_interactions (
    interaction_id         NVARCHAR(50)  NOT NULL PRIMARY KEY,
    user_id                NVARCHAR(50),
    product_id             NVARCHAR(50),
    session_id             NVARCHAR(50),
    interaction_type       NVARCHAR(30),
    interaction_timestamp  DATETIME2(7), 
    dwell_time_ms          INT,
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.ecom_purchases', 'U') IS NOT NULL DROP TABLE silver.ecom_purchases;
GO
CREATE TABLE silver.ecom_purchases (
    purchase_id      NVARCHAR(50)  NOT NULL PRIMARY KEY,
    order_id         NVARCHAR(50),
    user_id          NVARCHAR(50),
    product_id       NVARCHAR(50),
    session_id       NVARCHAR(50),
    interaction_id   NVARCHAR(50),
    quantity         INT,
    unit_price       DECIMAL(10,2),
    total_amount     DECIMAL(12,2),
    order_date       DATETIME2(7),
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.ecom_reviews', 'U') IS NOT NULL DROP TABLE silver.ecom_reviews;
GO
CREATE TABLE silver.ecom_reviews (
    review_id             NVARCHAR(50)  NOT NULL PRIMARY KEY,
    user_id               NVARCHAR(50),
    product_id            NVARCHAR(50),
    purchase_id           NVARCHAR(50),    -- NULL = unverified review
    rating                INT,
    title                 NVARCHAR(200),
    review_text           NVARCHAR(2000),
    review_date           DATETIME2(7),
    is_verified_purchase  BIT,             -- derived: purchase_id IS NOT NULL
    is_review_date_valid  BIT,             -- derived: validation check
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO