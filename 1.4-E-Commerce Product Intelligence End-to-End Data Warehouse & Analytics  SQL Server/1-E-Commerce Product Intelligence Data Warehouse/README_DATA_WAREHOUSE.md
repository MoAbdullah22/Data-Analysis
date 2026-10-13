# E-Commerce Data Warehouse — SQL Server

## Overview

This part of the project builds a SQL Server data warehouse for six synthetic e-commerce CSV datasets. The warehouse follows a three-layer Medallion Architecture:

**CSV source files → Bronze → Silver → Gold views → Reporting views**

The objective is to separate raw ingestion from data cleansing and from the business-oriented model used for analysis.

## Source Data

| CSV file | Rows | Subject |
|---|---:|---|
| `users.csv` | 10,000 | User profiles |
| `products.csv` | 1,000 | Product catalogue |
| `sessions.csv` | 19,315 | Browsing sessions |
| `interactions.csv` | 100,000 | Behavioural events |
| `purchases.csv` | 1,737 | Purchase records |
| `reviews.csv` | 1,253 | Product reviews |

The data covers January 2023 to May 2026 and is synthetic.

## Bronze Layer — Raw Data

The Bronze layer stores source data in raw landing tables using the `ecom_*` naming convention.

Implemented work:
- Created raw tables in the `bronze` schema.
- Built a stored procedure to load CSV files.
- Used SQL Server `BULK INSERT` with CSV-related options.
- Used truncate-and-insert for full-refresh loading.
- Added per-table and total load-duration messages.
- Added error reporting and error rethrowing for failed loads.

Cleansing and business transformations are handled in Silver rather than Bronze.

## Silver Layer — Cleansing and Transformation

The Silver layer contains cleaned and standardized tables.

Data-quality work includes:
- Inspecting identifier uniqueness and inconsistencies.
- Reviewing unwanted spaces and text values.
- Validating date values and converting date/time formats.
- Checking numeric values for invalid or illogical values.
- Reviewing distinct categorical values and standardizing inconsistent labels.
- Applying business rules and deriving corrected values where appropriate.

## Gold Layer — Dimensional Views

The Gold layer is implemented as SQL views over Silver data rather than a separate batch-loaded set of tables.

### Dimension views
- `gold.dim_customers`
- `gold.dim_products`
- `gold.dim_date` — generated calendar dimension

### Fact views
- `gold.fact_sales`
- `gold.fact_sessions`
- `gold.fact_interactions`
- `gold.fact_reviews`

### Fact-table grain

| Fact view | Grain |
|---|---|
| `gold.fact_sales` | One row per purchased order line |
| `gold.fact_sessions` | One row per browsing session |
| `gold.fact_interactions` | One row per behavioural event |
| `gold.fact_reviews` | One row per review |

The model uses customer and product surrogate keys and a date key in `YYYYMMDD` integer format.

**Surrogate key note:** customer and product keys are generated using `ROW_NUMBER()` ordered by business keys. Their values depend on the source ID set and ordering, so downstream models that cache these keys may need to be rebuilt after source ID changes.

## Reporting Views

Three reporting views are built on top of the dimensional views:

- `gold.report_customers` — customer spending, orders, recency, behaviour, and segmentation.
- `gold.report_products` — product funnel, sales, reviews, conversion metrics, and performance tiers.
- `gold.report_funnel` — session-to-cart-to-purchase funnel by device and traffic source.

## Workflow

1. Inspect source files and understand table relationships.
2. Create Bronze landing tables.
3. Load CSV files into Bronze using a stored procedure.
4. Profile and cleanse data into Silver.
5. Create Gold dimension and fact views.
6. Create reporting views on top of the dimensional model.
7. Use the prepared data for SQL analysis and Excel reporting.

## Technologies

SQL Server, T-SQL, stored procedures, `BULK INSERT`, Medallion Architecture, data-quality checks, SQL views, and dimensional modeling.

## Scope and Limitations

This project uses synthetic data. The Gold layer consists of views, so it is queried from the underlying Silver data rather than refreshed by a separate Gold-table load. The project does not claim cloud orchestration, a real-time pipeline, or measured business improvements.

## Author

**Mohamed Abdullah Ali**  
GitHub: [MoAbdullah22](https://github.com/MoAbdullah22)
