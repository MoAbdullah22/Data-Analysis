# 📊 Telco Customer Churn Analytics & Retention Strategy

## Executive Customer Retention & Lifecycle Performance Analysis

A comprehensive Data Analytics and Business Intelligence project focused on analyzing **customer churn, tenure lifecycles, contract exposure, payment friction, and service bundling efficiency** using the Telecom Customer Churn dataset.

The project was developed as a business case study with the objective of transforming raw operational data into meaningful insights and actionable retention strategies to mitigate revenue loss.

---

# 📌 Project Overview

The purpose of this project was not simply to build dashboards.

The analysis followed an end-to-end data analytics workflow:

> **Raw Data → Data Understanding → Data Quality Assessment → Data Preparation → Exploratory Analysis → Dimensional Modeling → Business Intelligence → Executive Insights**

The project focuses on answering important business questions related to:

- Customer churn patterns and overall lifecycle retention
- Revenue risk and monetary exposure across customer segments
- Contract vulnerability and payment method friction
- Service ecosystem engagement and product cross-selling impact
- Senior citizen and demographic vulnerability
- Targeted customer retention strategie

---

# 🎯 Business Objectives

The analysis focuses on identifying opportunities and risks across the company's customer base to increase lifetime value and reduce subscriber attrition.

### Key focus areas:

1. **Retention & Lifecycle Performance**
   - How is the business performing regarding overall customer retention?
   - When in the customer lifecycle does churn peak, and how does tenure impact attrition?

2. **Contract & Commitment Vulnerability**
   - Which contract types carry the highest churn risk?
   - How effective are annual commitments at stabilizing revenue?

3. **Payment Method Friction**
   - How do payment methods impact customer retention?
   - Do manual payment methods show higher churn compared to automated billing options?

4. **Service Ecosystem & Cross-Selling Efficiency**
   - How does additional service adoption (Online Security, Tech Support, Backup) affect retention rates?
   - Does bundling multiple services create customer stickiness?

5. **Demographic & Behavioral Vulnerability**
   - Which demographic segments (e.g., senior citizens, single-line subscribers) display elevated churn risk?
   - How does tech support availability influence retention across vulnerable segments?

---

# 📊 Key Findings

The analysis identified several critical business insights.

### 📉 Churn & Revenue Exposure

- **26.5% Overall Churn Rate** (1,869 churned customers out of 7,043 total)
- **$139.1K Monthly Charges Lost** to customer churn
- **63.1% First-Year Churn Exposure** (911 of total churned customers leave within their first 12 months)

---

### ⏳ Customer Lifecycle & Tenure Dynamics

- **0–12 Months:** 45.9% Churn Rate
- **13–24 Months:** 28.7% Churn Rate
- **25–48 Months:** 18.9% Churn Rate
- **49–72 Months:** 3.2% Churn Rate

> **Key Lifecycle Takeaway:** Churn drops from 45.9% in the first year to 3.2% by years 4–6—a **14x reduction** across the customer lifecycle.

---

### 📄 Contract & Payment Friction

- **Month-to-Month Contracts:** 43.1% Churn Rate (highest risk profile)
- **One-Year Contracts:** 11.3% Churn Rate
- **Two-Year Contracts:** 2.8% Churn Rate

- **Electronic Check:** 32.1% Churn Rate
- **Mailed Check:** 19.1% Churn Rate
- **Bank Transfer (Automatic):** 16.7% Churn Rate
- **Credit Card (Automatic):** 15.2% Churn Rate

---

### 📦 Service Ecosystem Impact

The analysis showed that customer retention directly scales with additional service adoption.

- **Low Service Adoption (0–1 Add-ons):** 32.6% Churn Rate
- **Medium Service Adoption (2–3 Add-ons):** 24.1% Churn Rate
- **High Service Adoption (4+ Add-ons):** 22.0% Churn Rate

This confirms that service ecosystem integration builds **product stickiness and reduces attrition**.

---

# 🛠️ Tools & Technologies

### Data Processing & Analysis

- Python (Pandas, NumPy)
- Plotly / Matplotlib (Exploratory Visualizations)
- SQL (Analytical Queries & Data Extraction)
- Jupyter Notebook

### Business Intelligence & Reporting

- Power BI
- Power Query (ETL & Transformation)=
- DAX (Data Analysis Expressions for Measures & Time Intelligence)

### Key Analytics Skills

- Exploratory Data Analysis (EDA)
- Data Cleaning & Data Quality Handling
- Dimensional Data Modeling (Star Schema)
- DAX Metric Development
- Customer Segmentation & Cohort Analysis
- Data Storytelling & Strategic Reporting

---

# 🔄 Project Workflow

## Phase 1 — Problem Definition & KPI Setup

The project began by establishing key retention metrics to evaluate subscriber attrition and monetary loss.

The primary focus areas included:

- Churn Rate & Customer Loss Count
- Monthly Charges at Risk vs. Retained Revenue
- Tenure Lifecycle Cohort Performance
- Contract & Payment Channel Exposure
- Service Ecosystem Penetration Rates

---

## Phase 2 — Data Understanding

The dataset structure was systematically evaluated:

- **Total Records:** 7,043 unique customer accounts
- **Granularity:** One row per subscriber account
- **Attributes:** Demographics, contract specs, billing methods, subscribed services, monthly/total charges, and churn indicators

---

## Phase 3 — Data Quality & Integrity Assessment

The dataset was assessed for potential issues to ensure reliable analytical outputs:

- **Missing Values:** Identified blank entries in `Total Charges` corresponding strictly to 0-tenure new subscribers (Missing Not At Random - MNAR). Imputed appropriately without distorting lifetime value metrics.
- **Data Leakage Risks:** Isolated outcome-dependent attributes (such as post-hoc `Churn Score` and `Churn Reason` fields) from baseline exploratory modeling.
- **Data Type Corrections:** Converted numerical charges, tenure durations, and categorical boolean flags into analytical data types.

---

## Phase 4 — Data Preparation & Feature Engineering

Using Python and Power Query, features were engineered to support deeper analytical segmentation:

- **Tenure Cohorts:** Grouped raw tenure (months) into actionable buckets (`0–12m`, `13–24m`, `25–48m`, `49–72m`).
- **Service Bundle Count:** Aggregated total active add-on services (Online Security, Online Backup, Device Protection, Tech Support, Streaming TV/Movies) per subscriber.
- **Payment Classification:** Categorized payment channels into **Manual** vs. **Automatic** billing.

---

# 🧩 Data Model

The project utilizes a star-schema dimensional model centered around customer account transactions.

### Fact Table

## Fact Customer Churn

The central fact table contains customer account metrics and transactional statuses.

Examples include:

- Monthly Charges
- Total Charges
- Tenure Months
- Churn Status (1 = Churned, 0 = Retained)

### Grain

> **One row represents one unique customer account.**
---

# 📐 Dimension Tables

The dimensional model separates entity context into dedicated dimensions:

### Dim Customer Demographics

Contains customer profile information (Gender, Senior Citizen, Partner, Dependents).

### Dim Contract & Billing

Contains subscription contract types, paperless billing preferences, and payment channels.

### Dim Service Portfolio

Contains primary internet/phone service configurations and secondary add-on services.

### Dim Date / Tenure Cohort

Supports tenure lifecycle grouping and duration-based analysis.

---

# 📏 Key DAX KPIs & Measures

The Power BI report leverages custom DAX calculations:

### Business & Churn Metrics

- **Total Customers:** `COUNT(Fact_Churn[CustomerID])`
- **Churned Customers:** `CALCULATE(COUNT(Fact_Churn[CustomerID]), Fact_Churn[Churn] = "Yes")`
- **Churn Rate:** `DIVIDE([Churned Customers], [Total Customers], 0)`
- **Monthly Revenue Lost:** `CALCULATE(SUM(Fact_Churn[MonthlyCharges]), Fact_Churn[Churn] = "Yes")`

### Lifecycle & Ratio Intelligence

- **First-Year Churn Share:** `DIVIDE([First Year Churned Customers], [Churned Customers], 0)`
- **Avg Tenure (Retained vs. Churned):** Average customer lifetime duration split by churn status.
- **Auto-Pay Adoption Rate:** % of total subscriber base utilizing automatic payment methods.

---

# 📊 Dashboard Pages

## 1️⃣ Executive Overview

Provides a high-level summary of total churn rates, revenue exposure, key customer segments, and high-level contract risks.

![Executive Overview](dashboards/executive_overview.png)

---

## 2️⃣ Customer Churn Profile & Demographics

Examines customer behavioral demographics, senior citizen churn risks, and household structure impacts.

![Customer Churn Profile](dashboards/customer_profile.png)

---

## 3️⃣ Operational Churn Drivers & Service Analysis

Deep-dives into contract vulnerability, payment method friction, tenure decay curves, and add-on service adoption patterns.

![Churn Drivers](dashboards/churn_drivers.png)

---

## 4️⃣ Strategic Retention & Action Plan

Interactive decision tool prioritizing high-risk customer cohorts for targeted intervention and campaign modeling.

![Retention Strategy](dashboards/retention_strategy.png)

---

# 💡 Strategic Recommendations

Based on the empirical findings, four core strategic initiatives are recommended:

### 🛡️ 1. First-Year Protection Program

* **Action:** Launch early-onboarding touchpoints during days 30, 60, and 90.
* **Target:** First-year subscribers (responsible for **63.1% of total churn**).
* **Goal:** Stabilize accounts through early technical assistance to transition users into Year 2+, where churn rate drops significantly.

---

### 📄 2. Contract Migration Campaigns

* **Action:** Offer targeted bill credits or discounted feature add-ons for converting to 1-year or 2-year plans.
* **Target:** Month-to-month subscribers (currently exhibiting a **43.1% churn rate**).
* **Goal:** Shift high-risk flexible accounts into long-term commitments.

---

### 💳 3. Auto-Pay Incentive Strategy

* **Action:** Provide a recurring $2–$5 monthly bill credit for switching to Credit Card or Bank Transfer Auto-Pay.
* **Target:** Electronic Check customers (churning at **32.1%**).
* **Goal:** Eliminate manual payment friction and failed-payment service interruptions.

---

### 📦 4. Service Ecosystem Cross-Selling

* **Action:** Package essential security add-ons (Online Security, Tech Support) into primary internet tiers.
* **Target:** Single-service or low-engagement subscribers.
* **Goal:** Increase service adoption from 0–1 services up to 3+ services, driving churn rates down from **32.6% to 22.0%**.

---

# 📂 Repository Structure

```text
Telco-Customer-Churn-Analytics/
│
├── notebooks/
│   ├── 01_Telco_Customer_Churn_End-to-End Data Science.ipynb
│ 
│
├── dashboards/
│   ├── executive_overview.png
│   ├── customer_profile.png
│   ├── churn_drivers.png
│   └── retention_strategy.png
│
├── reports/
│   └── telco_churn_executive_case_study.pdf
│
├── docs/
│   ├── business_questions.md (analytical_queries.sql)
│
└── README.md