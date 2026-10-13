# E-Commerce Product Intelligence — Data Warehouse & Analytics

## Project Overview

This project explores a synthetic e-commerce dataset and organizes it into a SQL Server data warehouse to support structured analysis and reporting.

The work covers source exploration, raw data ingestion, data cleaning and standardization, dimensional modeling, SQL analysis, and Excel-based reporting.

## Source Data

The project uses six CSV files:

| Source file | Rows |
|---|---:|
| `users.csv` | 10,000 |
| `products.csv` | 1,000 |
| `sessions.csv` | 19,315 |
| `interactions.csv` | 100,000 |
| `purchases.csv` | 1,737 |
| `reviews.csv` | 1,253 |

The data covers January 2023 to May 2026.

## Tools

- Microsoft SQL Server and T-SQL
- Stored procedures and `BULK INSERT`
- Medallion Architecture
- Data profiling, cleansing, and standardization
- Star schema and dimensional modeling
- SQL views
- Microsoft Excel

## Workflow

### 1. Source exploration
I examined the six source files to understand their structure, purpose, relationships, and analytical value. I documented the data integration flow before building the warehouse.

### 2. Bronze Layer — Raw ingestion
Created raw landing tables and stored procedures to load CSV files into SQL Server using `BULK INSERT`. The loading scripts use full-refresh loading and include duration messages and error handling.

### 3. Silver Layer — Cleansing and standardization
Profiled and prepared the data for analysis. Work included checking identifier quality, investigating inconsistencies, handling unwanted spaces, validating and converting dates, reviewing numeric values, and standardizing inconsistent categorical labels. Business rules were applied where appropriate.

### 4. Gold Layer — Dimensional model
Created a star-schema model as SQL views over Silver data:
- 3 dimension views
- 4 fact views
- 3 business-oriented reporting views

The fact-table grain is defined for purchased order lines, browsing sessions, behavioural interactions, and reviews.

### 5. Excel reporting
Used Excel to prepare reporting outputs for customer behaviour, product performance, and session-to-purchase funnel analysis.

## Documentation

The project includes diagrams for:
- High-level architecture
- Data flow / data lineage
- Source data integration
- Sales data mart / dimensional model
- Project roadmap

## Repository Guides

- `README_DATA_WAREHOUSE.md` — warehouse layers, ingestion, cleansing, and dimensional model.
- `README_DATA_ANALYTICS.md` — SQL exploration and analytical workflow.

## Scope and Limitations

This is a portfolio project built using a synthetic dataset. It documents the implemented workflow and analysis structure; it does not claim measured business improvements or production deployment. The Gold layer is implemented using views rather than a separate Gold-table loading process.

## Author

**Mohamed Abdullah Ali**  
GitHub: [MoAbdullah22](https://github.com/MoAbdullah22)
