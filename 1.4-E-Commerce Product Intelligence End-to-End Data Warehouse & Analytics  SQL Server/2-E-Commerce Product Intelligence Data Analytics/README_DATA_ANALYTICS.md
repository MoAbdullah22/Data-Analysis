# E-Commerce Product Intelligence — SQL Analytics

## Overview

This part of the project uses SQL Server to explore the e-commerce data and answer analytical questions after the data has been organized into the warehouse.

The workflow is divided into exploratory analysis and advanced analysis. The objective is to understand the dataset, examine patterns and performance, and prepare business-oriented reporting outputs.

## Data Used

The synthetic dataset contains six CSV files covering users, products, sessions, interactions, purchases, and reviews. The data covers January 2023 to May 2026.

## Exploratory Data Analysis

The SQL exploration scripts cover:

1. **Database exploration** — inspect database objects and available data.
2. **Dimension exploration** — examine entities and their attributes.
3. **Date exploration** — understand date ranges and time-related fields.
4. **Measures exploration** — inspect key numeric measures and counts.
5. **Magnitude analysis** — compare the scale of measures across the data.
6. **Ranking analysis** — identify top and bottom items using ranking queries.

## Advanced Analytics

The advanced analysis scripts cover:

7. **Change over time** — examine how measures vary across time.
8. **Cumulative analysis** — calculate running or accumulated measures.
9. **Performance analysis** — compare performance across periods, including year-over-year and month-over-month analysis where applicable.
10. **Part-to-whole analysis** — examine proportional contribution.
11. **Data segmentation** — group entities into meaningful segments.
12. **Reporting** — prepare SQL reporting outputs for customer, product, and funnel analysis.

These headings describe the scope of the analysis scripts. Specific conclusions should be taken from query results rather than assumed from the topic names.

## Business-Oriented Reporting

The Gold reporting views support three main areas:

- **Customer reporting:** spending, order activity, recency, behaviour, and segmentation.
- **Product reporting:** sales, reviews, funnel metrics, conversion rates, and performance tiers.
- **Funnel reporting:** session-to-cart-to-purchase activity by device type and traffic source.

Excel is used to prepare reporting outputs based on the available data.

## SQL Analysis Concepts

The project includes query patterns for filtering, sorting, joins, aggregations, date-related analysis, ranking, cumulative calculations, period-over-period comparisons, ratios, proportional analysis, segmentation, and views. Individual features should be listed only where they appear in the actual scripts.

## Deliverables

- SQL scripts for exploratory analysis.
- SQL scripts for advanced analytics.
- Gold-layer customer, product, and funnel reporting views.
- Excel reporting outputs.
- Documentation diagrams for architecture, data flow, and dimensional modeling.


## Author

**Mohamed Abdullah Ali**  
GitHub: [MoAbdullah22](https://github.com/MoAbdullah22)
