-- ============================================================
--   TELCO CUSTOMER CHURN — SQL INTERVIEW QUESTIONS & ANSWERS
--   Based on: End-to-End Data Science Project by Mohamed Abdullah Ali
--   Dataset : IBM Telco Customer Churn | 7,043 customers
-- ============================================================
--
--  TABLE SCHEMA (used in all questions below)
--
--  telco_customers (
--      CustomerID          VARCHAR,
--      Gender              VARCHAR,       -- 'Male' / 'Female'
--      SeniorCitizen       INT,           -- 0 = No, 1 = Yes
--      Partner             VARCHAR,       -- 'Yes' / 'No'
--      Dependents          VARCHAR,       -- 'Yes' / 'No'
--      TenureMonths        INT,
--      PhoneService        VARCHAR,       -- 'Yes' / 'No'
--      MultipleLines       VARCHAR,
--      InternetService     VARCHAR,       -- 'DSL' / 'Fiber optic' / 'No'
--      OnlineSecurity      VARCHAR,       -- 'Yes' / 'No' / 'No internet service'
--      OnlineBackup        VARCHAR,
--      DeviceProtection    VARCHAR,
--      TechSupport         VARCHAR,
--      StreamingTV         VARCHAR,
--      StreamingMovies     VARCHAR,
--      Contract            VARCHAR,       -- 'Month-to-month' / 'One year' / 'Two year'
--      PaperlessBilling    VARCHAR,       -- 'Yes' / 'No'
--      PaymentMethod       VARCHAR,
--      MonthlyCharges      DECIMAL(10,2),
--      TotalCharges        DECIMAL(10,2),
--      ChurnLabel          VARCHAR,       -- 'Yes' / 'No'
--      ChurnValue          INT,           -- 1 = Churned, 0 = Stayed
--      CLTV                INT            -- Customer Lifetime Value
--  )
--
-- ============================================================


-- ████████████████████████████████████████████
--            LEVEL 1 — BASIC
-- ████████████████████████████████████████████


-- ─────────────────────────────────────────────────────────
-- Q1: How many customers are in the dataset?
-- Business Context: First thing you check — dataset size.
-- ─────────────────────────────────────────────────────────
SELECT COUNT(*) AS total_customers
FROM telco_customers;

-- Answer: 7,043 customers


-- ─────────────────────────────────────────────────────────
-- Q2: How many customers churned and how many stayed?
-- Business Context: Understand the target variable distribution.
-- ─────────────────────────────────────────────────────────
SELECT
    ChurnLabel,
    COUNT(*)  AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM telco_customers
GROUP BY ChurnLabel;

-- Answer:
-- No  → ~5,174 customers (~73.5%)
-- Yes → ~1,869 customers (~26.5%)
-- Business Insight: Dataset is imbalanced → majority class is "Stayed"


-- ─────────────────────────────────────────────────────────
-- Q3: What is the average monthly charge for all customers?
-- Business Context: Understand pricing baseline.
-- ─────────────────────────────────────────────────────────
SELECT ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge
FROM telco_customers;


-- ─────────────────────────────────────────────────────────
-- Q4: What are the different contract types and how many
--     customers are on each?
-- Business Context: Contract is the #1 churn predictor.
-- ─────────────────────────────────────────────────────────
SELECT
    Contract,
    COUNT(*) AS customer_count
FROM telco_customers
GROUP BY Contract
ORDER BY customer_count DESC;

-- Answer:
-- Month-to-month → highest count (~3,875)
-- Two year       → medium
-- One year       → lowest


-- ─────────────────────────────────────────────────────────
-- Q5: How many customers have missing TotalCharges?
-- Business Context: In the notebook we found missing values
--                   in TotalCharges belong to new customers
--                   with zero tenure (MNAR).
-- ─────────────────────────────────────────────────────────
SELECT COUNT(*) AS missing_total_charges
FROM telco_customers
WHERE TotalCharges IS NULL;


-- ─────────────────────────────────────────────────────────
-- Q6: List all distinct payment methods available.
-- ─────────────────────────────────────────────────────────
SELECT DISTINCT PaymentMethod
FROM telco_customers
ORDER BY PaymentMethod;

-- Answer: 4 methods:
-- Bank transfer (automatic)
-- Credit card (automatic)
-- Electronic check
-- Mailed check


-- ─────────────────────────────────────────────────────────
-- Q7: What is the minimum, maximum, and average tenure
--     (in months) across all customers?
-- ─────────────────────────────────────────────────────────
SELECT
    MIN(TenureMonths) AS min_tenure,
    MAX(TenureMonths) AS max_tenure,
    ROUND(AVG(TenureMonths), 2) AS avg_tenure
FROM telco_customers;


-- ─────────────────────────────────────────────────────────
-- Q8: How many senior citizen customers are there?
-- Business Context: Senior citizens churn at higher rates
--                   (~41%) vs non-seniors (~23.6%).
-- ─────────────────────────────────────────────────────────
SELECT
    CASE WHEN SeniorCitizen = 1 THEN 'Senior' ELSE 'Non-Senior' END AS customer_type,
    COUNT(*) AS count
FROM telco_customers
GROUP BY SeniorCitizen;


-- ████████████████████████████████████████████
--          LEVEL 2 — INTERMEDIATE
-- ████████████████████████████████████████████


-- ─────────────────────────────────────────────────────────
-- Q9: What is the churn rate for each contract type?
-- Business Context: Month-to-month = highest churn risk.
--                   This is the #1 churn driver in the project.
-- ─────────────────────────────────────────────────────────
SELECT
    Contract,
    COUNT(*)                                              AS total_customers,
    SUM(ChurnValue)                                       AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)         AS churn_rate_pct
FROM telco_customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- Expected result:
-- Month-to-month → highest churn rate (~42%)
-- One year       → medium (~11%)
-- Two year       → lowest (~3%)


-- ─────────────────────────────────────────────────────────
-- Q10: Do senior citizens churn more than non-seniors?
-- Business Context: Confirmed in EDA — seniors churn ~41%
--                   vs non-seniors ~23.6%.
-- ─────────────────────────────────────────────────────────
SELECT
    CASE WHEN SeniorCitizen = 1 THEN 'Senior' ELSE 'Non-Senior' END AS customer_group,
    COUNT(*)                                             AS total,
    SUM(ChurnValue)                                      AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM telco_customers
GROUP BY SeniorCitizen
ORDER BY churn_rate_pct DESC;


-- ─────────────────────────────────────────────────────────
-- Q11: What is the average monthly charge for churned vs
--      non-churned customers?
-- Business Context: Higher monthly charges → higher churn risk.
--                   Confirmed as top-5 churn driver via SHAP.
-- ─────────────────────────────────────────────────────────
SELECT
    ChurnLabel,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge,
    ROUND(AVG(TenureMonths), 2)   AS avg_tenure_months
FROM telco_customers
GROUP BY ChurnLabel;

-- Expected: churned customers pay more per month but have lower tenure


-- ─────────────────────────────────────────────────────────
-- Q12: What is the churn rate by internet service type?
-- Business Context: Fiber optic customers churn significantly
--                   more than DSL customers.
-- ─────────────────────────────────────────────────────────
SELECT
    InternetService,
    COUNT(*)                                             AS total,
    SUM(ChurnValue)                                      AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM telco_customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;


-- ─────────────────────────────────────────────────────────
-- Q13: How does the absence of TechSupport affect churn?
-- Business Context: No TechSupport = higher churn.
--                   Top-3 churn driver confirmed by SHAP.
-- ─────────────────────────────────────────────────────────
SELECT
    TechSupport,
    COUNT(*)                                             AS total,
    SUM(ChurnValue)                                      AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM telco_customers
GROUP BY TechSupport
ORDER BY churn_rate_pct DESC;


-- ─────────────────────────────────────────────────────────
-- Q14: Which payment method has the highest churn rate?
-- Business Context: Electronic Check is a consistent churn
--                   signal — top-4 churn driver (SHAP).
-- ─────────────────────────────────────────────────────────
SELECT
    PaymentMethod,
    COUNT(*)                                             AS total,
    SUM(ChurnValue)                                      AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM telco_customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- Expected: Electronic check → highest churn rate


-- ─────────────────────────────────────────────────────────
-- Q15: Segment customers by tenure into groups:
--      New (0–12 months), Medium (13–36), Long-term (37+)
--      and show churn rate per group.
-- Business Context: Short tenure = high risk. Hypothesis
--                   from Phase 2 confirmed in EDA.
-- ─────────────────────────────────────────────────────────
SELECT
    CASE
        WHEN TenureMonths BETWEEN 0  AND 12 THEN 'New (0–12 months)'
        WHEN TenureMonths BETWEEN 13 AND 36 THEN 'Medium (13–36 months)'
        ELSE                                     'Long-term (37+ months)'
    END AS tenure_group,
    COUNT(*)                                             AS total,
    SUM(ChurnValue)                                      AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM telco_customers
GROUP BY tenure_group
ORDER BY churn_rate_pct DESC;


-- ─────────────────────────────────────────────────────────
-- Q16: What are the top 10 customers by CLTV who churned?
-- Business Context: Losing high-CLTV churners costs the most.
--                   These should be in the Critical tier.
-- ─────────────────────────────────────────────────────────
SELECT
    CustomerID,
    TenureMonths,
    MonthlyCharges,
    CLTV,
    Contract,
    PaymentMethod
FROM telco_customers
WHERE ChurnLabel = 'Yes'
ORDER BY CLTV DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────
-- Q17: Count how many additional services each customer
--      uses (OnlineSecurity, OnlineBackup, DeviceProtection,
--      TechSupport, StreamingTV, StreamingMovies).
-- Business Context: Feature Engineering from the notebook —
--                   more services = more loyal customers.
-- ─────────────────────────────────────────────────────────
SELECT
    CustomerID,
    ChurnLabel,
    (CASE WHEN OnlineSecurity   = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN OnlineBackup     = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN TechSupport      = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN StreamingTV      = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN StreamingMovies  = 'Yes' THEN 1 ELSE 0 END)  AS additional_services_count
FROM telco_customers
ORDER BY additional_services_count DESC;


-- ─────────────────────────────────────────────────────────
-- Q18: What is the churn rate for customers grouped by
--      number of additional services?
-- Business Context: Validates hypothesis: more services = lower churn.
-- ─────────────────────────────────────────────────────────
SELECT
    (CASE WHEN OnlineSecurity   = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN OnlineBackup     = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN TechSupport      = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN StreamingTV      = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN StreamingMovies  = 'Yes' THEN 1 ELSE 0 END)  AS services_count,
    COUNT(*)                                                  AS total,
    SUM(ChurnValue)                                           AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)             AS churn_rate_pct
FROM telco_customers
GROUP BY services_count
ORDER BY services_count;

-- Expected: churn rate decreases as services_count increases


-- ─────────────────────────────────────────────────────────
-- Q19: Find all customers with missing TotalCharges and
--      verify they have zero or null tenure.
-- Business Context: MNAR analysis from Phase 3.
--                   Solution: replace NULL with 0.
-- ─────────────────────────────────────────────────────────
SELECT
    CustomerID,
    TenureMonths,
    MonthlyCharges,
    TotalCharges,
    ChurnLabel
FROM telco_customers
WHERE TotalCharges IS NULL
ORDER BY TenureMonths;

-- Expected: all have TenureMonths = 0 (new customers)


-- ─────────────────────────────────────────────────────────
-- Q20: What percentage of Fiber optic internet customers
--      are on a Month-to-Month contract?
-- Business Context: Highest-risk combination = Fiber + M2M.
-- ─────────────────────────────────────────────────────────
SELECT
    InternetService,
    Contract,
    COUNT(*)                                              AS total,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY InternetService), 2) AS pct_within_internet_type
FROM telco_customers
WHERE InternetService = 'Fiber optic'
GROUP BY InternetService, Contract
ORDER BY pct_within_internet_type DESC;


-- ████████████████████████████████████████████
--           LEVEL 3 — ADVANCED
-- ████████████████████████████████████████████


-- ─────────────────────────────────────────────────────────
-- Q21: Rank customers within each contract type by their
--      monthly charges (highest first) using window functions.
-- ─────────────────────────────────────────────────────────
SELECT
    CustomerID,
    Contract,
    MonthlyCharges,
    ChurnLabel,
    RANK() OVER (
        PARTITION BY Contract
        ORDER BY MonthlyCharges DESC
    ) AS rank_within_contract
FROM telco_customers;


-- ─────────────────────────────────────────────────────────
-- Q22: For each customer, calculate:
--      estimated_total = MonthlyCharges × TenureMonths
--      and compare it with actual TotalCharges.
--      Flag customers where the difference > 10%.
-- Business Context: Validates the formula found in EDA:
--                   TotalCharges ≈ MonthlyCharges × Tenure
-- ─────────────────────────────────────────────────────────
SELECT
    CustomerID,
    TenureMonths,
    MonthlyCharges,
    TotalCharges,
    ROUND(MonthlyCharges * TenureMonths, 2)             AS estimated_total,
    ROUND(ABS(TotalCharges - (MonthlyCharges * TenureMonths))
          / NULLIF(TotalCharges, 0) * 100, 2)           AS difference_pct,
    CASE
        WHEN ABS(TotalCharges - (MonthlyCharges * TenureMonths))
             / NULLIF(TotalCharges, 0) > 0.10
        THEN 'Flag'
        ELSE 'OK'
    END AS data_quality_flag
FROM telco_customers
WHERE TotalCharges IS NOT NULL
ORDER BY difference_pct DESC;


-- ─────────────────────────────────────────────────────────
-- Q23: Build a churn risk scoring table using SQL CASE.
--      Assign risk tiers like the ML model output:
--        Critical  → Month-to-month + Fiber + No TechSupport + Senior
--        High      → Month-to-month + Fiber OR No TechSupport
--        Moderate  → Month-to-month only
--        Low       → One year or Two year contract
-- Business Context: Replicates the Risk Tier system from Step 10
--                   without using a machine learning model.
-- ─────────────────────────────────────────────────────────
SELECT
    CustomerID,
    Contract,
    InternetService,
    TechSupport,
    SeniorCitizen,
    ChurnLabel,
    CASE
        WHEN Contract = 'Month-to-month'
             AND InternetService = 'Fiber optic'
             AND TechSupport     = 'No'
             AND SeniorCitizen   = 1             THEN '🔴 Critical'
        WHEN Contract = 'Month-to-month'
             AND (InternetService = 'Fiber optic'
                  OR TechSupport  = 'No')        THEN '🟠 High'
        WHEN Contract = 'Month-to-month'         THEN '🟡 Moderate'
        ELSE                                          '🟢 Low'
    END AS risk_tier
FROM telco_customers
ORDER BY
    CASE
        WHEN Contract = 'Month-to-month'
             AND InternetService = 'Fiber optic'
             AND TechSupport = 'No'
             AND SeniorCitizen = 1 THEN 1
        WHEN Contract = 'Month-to-month'
             AND (InternetService = 'Fiber optic' OR TechSupport = 'No') THEN 2
        WHEN Contract = 'Month-to-month' THEN 3
        ELSE 4
    END;


-- ─────────────────────────────────────────────────────────
-- Q24: What is the churn rate for each risk tier defined
--      in Q23? (CTE version)
-- ─────────────────────────────────────────────────────────
WITH risk_scored AS (
    SELECT
        CustomerID,
        ChurnValue,
        CASE
            WHEN Contract = 'Month-to-month'
                 AND InternetService = 'Fiber optic'
                 AND TechSupport     = 'No'
                 AND SeniorCitizen   = 1             THEN '🔴 Critical'
            WHEN Contract = 'Month-to-month'
                 AND (InternetService = 'Fiber optic'
                      OR TechSupport  = 'No')        THEN '🟠 High'
            WHEN Contract = 'Month-to-month'         THEN '🟡 Moderate'
            ELSE                                          '🟢 Low'
        END AS risk_tier
    FROM telco_customers
)
SELECT
    risk_tier,
    COUNT(*)                                             AS total_customers,
    SUM(ChurnValue)                                      AS actual_churners,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM risk_scored
GROUP BY risk_tier
ORDER BY churn_rate_pct DESC;

-- Expected: Critical tier has highest real churn rate


-- ─────────────────────────────────────────────────────────
-- Q25: Find the running total of churned customers ordered
--      by TenureMonths using a window function.
-- Business Context: Shows at which tenure month we lose
--                   the most customers cumulatively.
-- ─────────────────────────────────────────────────────────
SELECT
    TenureMonths,
    COUNT(*)                    AS churned_this_month,
    SUM(COUNT(*)) OVER (
        ORDER BY TenureMonths
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                           AS cumulative_churned
FROM telco_customers
WHERE ChurnValue = 1
GROUP BY TenureMonths
ORDER BY TenureMonths;


-- ─────────────────────────────────────────────────────────
-- Q26: Using a CTE, find the top 3 churn reasons per
--      internet service type.
-- Business Context: Understand why different customer
--                   segments leave.
-- ─────────────────────────────────────────────────────────
WITH ranked_reasons AS (
    SELECT
        InternetService,
        ChurnLabel,
        Contract,
        PaymentMethod,
        COUNT(*) AS count,
        RANK() OVER (
            PARTITION BY InternetService
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM telco_customers
    WHERE ChurnValue = 1
    GROUP BY InternetService, ChurnLabel, Contract, PaymentMethod
)
SELECT *
FROM ranked_reasons
WHERE rnk <= 3;


-- ─────────────────────────────────────────────────────────
-- Q27: Calculate the month-over-month churn rate (simulate
--      using tenure buckets as time periods).
-- Business Context: Understand churn velocity over time.
-- ─────────────────────────────────────────────────────────
WITH monthly_buckets AS (
    SELECT
        TenureMonths                                      AS month_bucket,
        COUNT(*)                                          AS total_customers,
        SUM(ChurnValue)                                   AS churned_customers
    FROM telco_customers
    GROUP BY TenureMonths
),
with_lag AS (
    SELECT
        month_bucket,
        total_customers,
        churned_customers,
        ROUND(churned_customers * 100.0 / NULLIF(total_customers, 0), 2) AS churn_rate_pct,
        LAG(ROUND(churned_customers * 100.0 / NULLIF(total_customers, 0), 2))
            OVER (ORDER BY month_bucket)                  AS prev_month_churn_rate
    FROM monthly_buckets
)
SELECT
    month_bucket,
    total_customers,
    churned_customers,
    churn_rate_pct,
    prev_month_churn_rate,
    ROUND(churn_rate_pct - prev_month_churn_rate, 2) AS churn_rate_change
FROM with_lag
ORDER BY month_bucket;


-- ─────────────────────────────────────────────────────────
-- Q28: Identify duplicate CustomerIDs (data quality check).
-- Business Context: Phase 3 — Duplicated Records check.
--                   Result in notebook: 0 duplicates found.
-- ─────────────────────────────────────────────────────────
SELECT
    CustomerID,
    COUNT(*) AS occurrences
FROM telco_customers
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Expected: 0 rows (no duplicates in this dataset)


-- ─────────────────────────────────────────────────────────
-- Q29: What is the average CLTV per contract type and
--      churn status? Rank contract types by avg CLTV.
-- Business Context: Higher CLTV churners = biggest revenue loss.
-- ─────────────────────────────────────────────────────────
SELECT
    Contract,
    ChurnLabel,
    COUNT(*)                                            AS customers,
    ROUND(AVG(CLTV), 0)                                AS avg_cltv,
    ROUND(AVG(MonthlyCharges), 2)                      AS avg_monthly_charge,
    RANK() OVER (
        PARTITION BY ChurnLabel
        ORDER BY AVG(CLTV) DESC
    )                                                   AS cltv_rank
FROM telco_customers
GROUP BY Contract, ChurnLabel
ORDER BY ChurnLabel, avg_cltv DESC;


-- ─────────────────────────────────────────────────────────
-- Q30: Build a full churn summary report combining all
--      top 5 churn drivers found in the project:
--      Contract, Tenure, TechSupport, PaymentMethod, MonthlyCharges.
-- Business Context: This is the final business insights
--                   table — mirrors the EDA report.
-- ─────────────────────────────────────────────────────────
WITH enriched AS (
    SELECT
        CustomerID,
        ChurnValue,
        Contract,
        TechSupport,
        PaymentMethod,
        CASE
            WHEN TenureMonths BETWEEN 0  AND 12 THEN 'New'
            WHEN TenureMonths BETWEEN 13 AND 36 THEN 'Medium'
            ELSE 'Long-term'
        END AS tenure_segment,
        CASE
            WHEN MonthlyCharges < 35  THEN 'Low (<$35)'
            WHEN MonthlyCharges < 70  THEN 'Medium ($35–70)'
            ELSE                           'High (>$70)'
        END AS charge_segment,
        CASE
            WHEN Contract = 'Month-to-month'
                 AND InternetService = 'Fiber optic'
                 AND TechSupport     = 'No'
                 AND SeniorCitizen   = 1 THEN '🔴 Critical'
            WHEN Contract = 'Month-to-month'
                 AND (InternetService = 'Fiber optic' OR TechSupport = 'No')
                                          THEN '🟠 High'
            WHEN Contract = 'Month-to-month' THEN '🟡 Moderate'
            ELSE                                  '🟢 Low'
        END AS risk_tier
    FROM telco_customers
)
SELECT
    risk_tier,
    tenure_segment,
    charge_segment,
    COUNT(*)                                             AS total_customers,
    SUM(ChurnValue)                                      AS churned,
    ROUND(SUM(ChurnValue) * 100.0 / COUNT(*), 2)        AS churn_rate_pct,
    ROUND(AVG(ChurnValue) * 100.0, 2)                   AS avg_churn_probability
FROM enriched
GROUP BY risk_tier, tenure_segment, charge_segment
ORDER BY churn_rate_pct DESC
LIMIT 20;


-- ============================================================
--   QUICK REFERENCE: TOP 5 CHURN DRIVERS (from SHAP + EDA)
-- ============================================================
--   1. Contract Type     → Month-to-month churns at ~42%
--   2. Tenure Months     → New customers (0-12m) churn most
--   3. Tech Support      → No Tech Support = high churn risk
--   4. Payment Method    → Electronic check = high churn risk
--   5. Monthly Charges   → Higher charges → higher churn risk
-- ============================================================
