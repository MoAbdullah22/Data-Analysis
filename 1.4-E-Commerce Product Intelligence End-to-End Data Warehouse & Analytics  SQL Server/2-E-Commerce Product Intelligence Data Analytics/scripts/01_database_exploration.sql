/*
===============================================================================
Database Exploration                                         (Roadmap step 1)
===============================================================================
Author  : Mohamed Abdullah Ali
Purpose :
    - Explore the structure of the database: tables, columns and how they link.
    - Check that the data loaded completely (row counts).

Tables Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve a list of all tables in the database
SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME;

-- Retrieve all columns for a specific table (fact_sales)
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales'
ORDER BY ORDINAL_POSITION;

-- Retrieve all columns for a specific table (dim_customers)
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
ORDER BY ORDINAL_POSITION;

-- Which columns connect the tables? (every *_key column is a join column)
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
  AND COLUMN_NAME LIKE '%\_key' ESCAPE '\'
ORDER BY COLUMN_NAME, TABLE_NAME;

-- Row count of every table (expected: 10000 / 1000 / 1826 / 1737 / 19315 / 100000 / 1253)
SELECT 'dim_customers'     AS table_name, COUNT(*) AS row_count FROM gold.dim_customers     UNION ALL
SELECT 'dim_products',                    COUNT(*)              FROM gold.dim_products      UNION ALL
SELECT 'dim_date',                        COUNT(*)              FROM gold.dim_date          UNION ALL
SELECT 'fact_sales',                      COUNT(*)              FROM gold.fact_sales        UNION ALL
SELECT 'fact_sessions',                   COUNT(*)              FROM gold.fact_sessions     UNION ALL
SELECT 'fact_interactions',               COUNT(*)              FROM gold.fact_interactions UNION ALL
SELECT 'fact_reviews',                    COUNT(*)              FROM gold.fact_reviews;
