# 📊 DataCo Smart Supply Chain Analytics

## Executive Supply Chain & Business Performance Analysis

A comprehensive Data Analytics and Business Intelligence project focused on analyzing **sales, profitability, customers, products, discounts, and delivery performance** using the DataCo Smart Supply Chain dataset.

The project was developed as a business case study with the objective of transforming raw operational data into meaningful insights and actionable business recommendations.

---

# 📌 Project Overview

The purpose of this project was not simply to build dashboards.

The analysis followed an end-to-end data analytics workflow:

> **Raw Data → Data Understanding → Data Quality Assessment → Data Preparation → Data Modeling → Business Analysis → Dashboard → Executive Insights**

The project focuses on answering important business questions related to:

- Business performance
- Sales and profitability
- Discount efficiency
- Delivery performance
- Late delivery risk
- Customer behavior
- Market performance
- Product and category performance

---

# 🎯 Business Objectives

The analysis focuses on identifying opportunities and risks across the company's supply chain and commercial performance.

### Key focus areas:

1. **Business Performance**
   - How is the business performing overall?
   - How are sales, profit, orders, and customers changing over time?

2. **Sales & Profitability**
   - Which markets, departments, categories, and products generate the most revenue and profit?
   - How efficient is the company's profit generation?

3. **Discount & Pricing Analysis**
   - How do discounts impact profitability?
   - Does discounting improve business performance or reduce profit margins?

4. **Delivery & Late Delivery Risk**
   - Where is late delivery concentrated?
   - Which shipping modes have the highest delivery risk?
   - Which regions and departments require operational investigation?

5. **Customer & Market Analysis**
   - Which customer segments generate the highest value?
   - How does business performance differ across markets?

6. **Product & Category Analysis**
   - Which products are high-performing?
   - Which products generate strong sales but weak profitability?
   - Which products require strategic attention?

---

# 📊 Key Findings

The analysis identified several important business insights.

### 💰 Financial Performance

- **$33.05M Net Revenue**
- **$3.97M Net Profit**
- **12% Overall Profit Margin**
- **65,752 Orders**

---

### 🚚 Delivery Performance

- **54.82% Late Delivery Rate**
- **36,048 delayed orders**

A significant operational concern was identified in premium shipping services.

- **First Class:** 95.27% Late Delivery Rate
- **Second Class:** 76.72% Late Delivery Rate
- **Standard Class:** 38.13% Late Delivery Rate

This indicates that premium shipping modes should be prioritized for further operational investigation.

---

### 💸 Discount Analysis

The analysis showed that profitability is generally lower when discounts are applied.

A key insight from the project was:

> The margin impact appears to be associated more strongly with the decision to apply a discount than with the discount depth itself.

This suggests an opportunity to improve **discount eligibility and pricing governance**.

---

### 📈 Seasonality

The analysis identified recurring seasonal patterns in customer demand and sales performance.

These patterns can support:

- Demand forecasting
- Inventory planning
- Workforce planning
- Fulfillment capacity planning

---

# 🛠️ Tools & Technologies

### Programming & Data Analysis

- Python
- Pandas
- Jupyter Notebook

### Business Intelligence

- Power BI
- Power Query
- DAX

### Key Analytics Skills

- Data Cleaning
- Data Quality Assessment
- Exploratory Data Analysis
- Dimensional Data Modeling
- KPI Development
- Business Analysis
- Data Visualization
- Data Storytelling

---

# 🔄 Project Workflow

## Phase 1 — Problem Definition & KPI Setup

The project began by defining the main business areas and identifying the KPIs required to evaluate company performance.

The primary focus areas included:

- Revenue performance
- Profitability
- Discount efficiency
- Delivery performance
- Late delivery risk

---

## Phase 2 — Data Understanding

The dataset structure was carefully analyzed to understand:

- Number of records
- Unique customers
- Unique orders
- Order items
- Products
- Categories
- Relationships between entities

Special attention was given to understanding the dataset grain.

### Fact Table Grain

> **One row represents one product item within a specific order.**

This understanding was essential for building the Power BI data model and calculating business metrics correctly.

---

## Phase 3 — Data Quality Assessment

The dataset was assessed for potential data quality issues, including:

- Missing values
- Duplicate records
- Data type inconsistencies
- Invalid values
- Duplicate columns
- Columns with limited analytical value

Several unnecessary columns were removed because they did not contribute to the analytical objectives.

Examples include:

- Customer Email
- Customer Password
- Product Image
- Product Description
- ZIP Code fields

---

## Phase 4 — Data Preparation

The dataset was prepared for analysis using Power Query.

This included:

- Data type correction
- Column organization
- Column renaming
- Removing unnecessary fields
- Date transformation
- Preparing dimension tables

Date attributes were derived to support time-based analysis:

- Date
- Year
- Quarter
- Month Number
- Month Name
- Year-Month
- Day Name

---

# 🧩 Data Model

The project uses a dimensional model designed around a central transactional fact table.

### Fact Table

## Fact Orders

The fact table contains transactional measures associated with order items.

Examples include:

- Sales
- Order Item Quantity
- Order Item Discount
- Order Item Discount Rate
- Order Item Total
- Order Item Profit Ratio
- Order Profit Per Order
- Days for Shipping (Real)
- Days for Shipment (Scheduled)
- Late Delivery Risk

### Grain

> **One row represents one product item within one order.**

---

# 📐 Dimension Tables

The model includes descriptive dimensions that provide context for business events.

### Dim Customer

Contains customer-related descriptive information.

### Dim Product

Contains product and product category information.

### Dim Date

Supports time-based analysis and time intelligence calculations.

### Dim Shipping

Contains shipping-related descriptive information such as shipping mode.

### Dim Geography

Provides geographic context for orders and customers where applicable.

---

# 📏 Key KPIs

The Power BI model includes measures for:

### Business Performance

- Total Sales
- Total Profit
- Total Orders
- Total Customers
- Average Order Value

### Profitability

- Profit Margin
- Profit Contribution

### Discount Analysis

- Total Discount
- Discount Rate
- Discount Impact on Profitability

### Delivery Performance

- Late Delivery Rate
- Late Orders
- On-Time Orders
- Average Scheduled Shipping Days
- Average Actual Shipping Days
- Average Shipping Delay

### Time Intelligence

- Sales PY
- Sales YoY %
- Profit PY
- Profit YoY %
- Orders PY
- Orders YoY %
- Customers PY
- Customers YoY %
- MTD Sales
- QTD Sales
- YTD Sales

---

# 📊 Dashboard Pages

## 1️⃣ Executive Overview

Provides a high-level overview of:

- Revenue
- Profitability
- Customer growth
- Order performance
- Sales trends
- Discount efficiency

![Executive Overview](dashboards/executive_overview.png)

---

## 2️⃣ Operations & Delivery Deep Dive

Focused on identifying where late delivery risk is concentrated.

The dashboard analyzes:

- Late Delivery Rate
- Shipping Mode Performance
- Regional Delivery Risk
- Department-Level Delivery Performance
- Actual vs Scheduled Shipping Duration

![Operations & Delivery Deep Dive](dashboards/operations_delivery.png)

---

# 💡 Strategic Recommendations

Based on the analysis, several strategic recommendations were identified.

### 🚚 Delivery Performance

Conduct a detailed operational investigation into premium shipping modes, particularly First Class, to understand whether delays are associated with:

- Delivery planning
- Fulfillment execution
- Capacity constraints
- External logistics performance

---

### 💸 Discount Governance

Review discount eligibility policies to protect profit margins and ensure that discounts are used strategically.

---

### 📦 Seasonal Planning

Use recurring seasonal demand patterns to improve:

- Inventory planning
- Workforce allocation
- Fulfillment capacity

---

### 📊 Performance Monitoring

Develop continuous KPI monitoring for:

- Late delivery risk
- Profit margin
- Discount performance
- Sales growth
- Customer growth

---

# 📂 Repository Structure

```text
DataCo-Smart-Supply-Chain-Analytics/
│
├── notebooks/
│   ├── 01_data_understanding.ipynb
│   ├── 02_data_quality_assessment.ipynb
│   └── 03_data_analysis.ipynb
│
├── dashboards/
│   ├── executive_overview.png
│   ├── operations_delivery.png
│   └── data_model.png
│
├── reports/
│   └── executive_supply_chain_report.pdf
│
├── docs/
│   ├── business_questions.md
│   ├── data_dictionary.md
│   └── methodology.md
│
└── README.md