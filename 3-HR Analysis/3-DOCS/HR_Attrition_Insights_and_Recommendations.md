# HR Attrition Analytics — Insights & Recommendations

## Executive Summary

This report synthesizes the findings from the three HR Attrition Analytics dashboard pages:

1. **Who Is Leaving?**
2. **Why Are They Leaving?**
3. **Where Is the Organizational Risk?**

The analysis focuses on identifying where attrition is concentrated, which employee characteristics and work conditions are associated with higher attrition, and which workforce segments should receive retention attention first.

> **Analytical perspective:** The findings describe observed associations in the available HR dataset. They should not be interpreted as proof of causation. Cross-segment findings with small sample sizes should be treated as signals for further investigation rather than definitive root causes.

---

## 1. Executive Snapshot

| KPI | Result |
|---|---:|
| Total Employees | **1,470** |
| Employees Who Left | **237** |
| Overall Attrition Rate | **16.12%** |
| Active Employees | **1,233** |
| Highest Observed Role Attrition | **Sales Representative — 39.76%** |
| Largest Share of Leavers | **R&D — 56.12%** |

The overall attrition rate of **16.12%** provides the baseline for evaluating all employee segments.

Two different dimensions of risk emerge:

- **Risk intensity:** how high the attrition rate is within a segment.
- **Risk exposure:** how many employees the segment actually contributes to total departures.

These should be considered together when prioritizing retention activity.

---

# 2. WHO Is Leaving?

## 2.1 Age shows a non-linear pattern

| Age Group | Attrition Rate |
|---|---:|
| 18–25 | **35.77%** |
| 26–35 | **19.14%** |
| 36–45 | **9.19%** |
| 46–55 | **11.50%** |
| 55+ | **17.02%** |

The **18–25 group has the highest observed attrition rate at 35.77%**, more than twice the overall baseline.

Attrition reaches its lowest level among employees aged **36–45 (9.19%)**, then increases again among the **55+ group (17.02%)**.

### Business interpretation

The pattern indicates that attrition is **not simply declining with age**. Different age groups may require different retention approaches.

The data does **not** establish why the 55+ group has a higher rate, so explanations such as retirement should be treated as hypotheses requiring additional evidence.

---

## 2.2 Marital status shows a meaningful gap

| Marital Status | Attrition Rate |
|---|---:|
| Single | **25.53%** |
| Married | **12.48%** |
| Divorced | **10.09%** |

Single employees have an attrition rate roughly twice that of married employees.

This is a strong segmentation signal, but marital status should be treated as an **associated characteristic**, not a causal explanation.

---

## 2.3 Education field shows secondary differences

The highest observed attrition rates by education field are:

- **Human Resources — 25.93%**
- **Technical Degree — 24.24%**
- **Marketing — 22.01%**

These groups are above the overall attrition baseline of 16.12%.

Education field appears to be a weaker organizational segmentation variable than age and marital status and should be interpreted alongside department, role, and other employee-experience variables.

---

# 3. WHY Are Employees Leaving?

## 3.1 Overtime has one of the largest observed attrition gaps

| Overtime | Attrition Rate |
|---|---:|
| Yes | **30.53%** |
| No | **10.44%** |

Employees working overtime show approximately **2.9×** the attrition rate of employees who do not work overtime.

### Business interpretation

Overtime is one of the strongest observed associations in the dataset.

However, this does not prove that overtime itself causes employees to leave. Overtime may also be associated with workload, staffing levels, job role, department, or other conditions.

**Recommended investigation:** review workload distribution, staffing requirements, overtime frequency, and whether high-overtime teams are concentrated in particular roles.

---

## 3.2 Job involvement shows a strong gradient

Attrition varies substantially with job involvement:

- **Low:** 33.73%
- **Very High:** 9.03%

The observed range from **33.73% to 9.03%** represents a large difference.

### Business interpretation

Job involvement is one of the clearest engagement-related signals in the dataset.

The pattern supports investigating employee engagement and role design, but it should not be described as an independent causal driver without multivariate analysis.

---

## 3.3 Distance from home shows a smaller positive gradient

Attrition increases across distance bands, from approximately **13.55%** among employees living closest to work to **22.14%** in the farthest band.

The pattern is meaningful but smaller than the major role, job-level, and overtime differences.

### Business interpretation

Distance from home is better treated as a **contextual workforce exposure factor** rather than a primary retention driver.

Potential follow-up analysis could examine whether the effect changes by department, role, business travel, or overtime.

---

# 4. Compensation Shows More Than One Attrition Pattern

| Salary Band | Attrition Rate | Observed Pattern |
|---|---:|---|
| Up to $5k | **21.76%** | Leavers have lower average monthly income than stayers within the band and shorter tenure. |
| $5k–$10k | **11.14%** | Leavers have slightly higher average income than stayers within the band. |
| $10k–$15k | **13.51%** | Leavers are longer-tenured and have been longer without promotion. |
| $15k+ | **3.76%** | Very low attrition, with only 5 observed leavers. |

The **Up to $5k** band accounts for **68.78% of all attrition**.

Within that band:

- Leavers' average monthly income: **$2,827.83**
- Stayers' average monthly income: **$3,290.17**

This supports investigating compensation and pay progression as a potential retention factor. It does **not** establish financial hardship.

Within the **$5k–$10k** band, leavers have higher average income than stayers:

- Leavers: **$7,150.35**
- Stayers: **$6,787.17**

Therefore, lower compensation alone does not explain attrition in this segment. Market competitiveness, career progression, role mobility, job satisfaction, and workload are reasonable areas for further investigation.

---

## 4.1 Promotion-stagnation signal

Within the **$10k–$15k** band:

- Years at company/experience measure among leavers: **13.80**
- Among stayers: **11.58**
- Years since last promotion among leavers: **5.90**
- Among stayers: **4.05**

The observed pattern suggests that extended time without advancement may warrant investigation for this segment.

A defensible conclusion is:

> **Longer-tenured employees with extended time since promotion show higher attrition within the $10k–$15k salary band.**

---

# 5. WHERE Is the Organizational Risk?

## 5.1 Job Role is the strongest organizational segmentation

**Sales Representative** has the highest observed role-level attrition:

> **39.76%**

This is substantially above the 16.12% company baseline.

Role-level analysis should therefore be one of the primary lenses for retention planning.

---

## 5.2 Job Level shows a wide range

| Job Level | Attrition Rate |
|---|---:|
| Level 1 | **26.34%** |
| Level 2 | **9.74%** |
| Level 3 | **14.68%** |
| Level 4 | **4.72%** |
| Level 5 | **7.25%** |

Because the source dataset provides numeric job levels rather than formally documented business titles, the analysis should use **Level 1–Level 5** unless business definitions are independently documented.

---

## 5.3 Department risk must be interpreted with workforce size

Sales has the highest departmental attrition rate at approximately **20.6%**.

R&D has a lower departmental rate of **13.84%**, yet accounts for approximately **56.12% of all employee departures**.

This distinction is central to retention planning.

### Risk intensity vs. risk exposure

A segment can have a high attrition rate but contribute relatively few departures because its workforce is small.

A large segment can have a moderate attrition rate while generating a much larger number of departures.

Retention prioritization should therefore consider both **rate** and **exposure**.

---

# 6. Cross-Segment Risk Signals

## 6.1 Sales Representative + Overtime

Sales Representatives who also work overtime show:

> **66.7% attrition (n=24)**

This is the highest observed attrition rate among the analyzed cross-segments.

Because the subgroup contains 24 employees, it should be treated as a **high-priority signal requiring validation**, rather than a definitive organizational conclusion.

### Investigation priority

Review:

- workload distribution
- overtime frequency
- staffing levels
- seasonal demand
- sales targets
- scheduling
- travel requirements

---

## 6.2 Sales Representative + Frequent Travel

Sales Representatives who travel frequently show:

> **65.2% attrition (n=23)**

This is another strong cross-segment signal.

The relatively small subgroup size means the result should be validated before making a broad policy decision.

---

## 6.3 Frequent Travel within HR

Frequent travel shows the highest observed departmental travel-related attrition in HR:

> **36.36%**

This suggests that travel may interact differently with workforce conditions across departments.

The appropriate response is **department-specific investigation**, not necessarily a company-wide travel policy.

---

# 7. Risk Intensity vs. Organizational Exposure

One of the most important conclusions is that **the highest attrition rate is not automatically the highest organizational priority**.

### Sales Representative

- Attrition rate: **39.76%**
- Share of all leavers: **13.92%**
- Employees who left: **33**

### Laboratory Technician

- Attrition rate: **23.94%**
- Employees: **259**
- Employees who left: **62**
- Share of all leavers: **26.16%**

Laboratory Technicians therefore contribute substantially more actual departures despite having a lower attrition rate.

### Management implication

Retention resources should be prioritized using:

1. **Attrition rate — risk intensity**
2. **Employees lost / share of leavers — organizational exposure**
3. **Business criticality — where available**

---

# 8. Retention Priorities

## Priority 1 — Validate the Sales Representative + Overtime Signal

**Evidence:** 66.7% attrition, n=24.

### Recommended action

Conduct a targeted workload and staffing review for Sales Representatives.

Focus on whether overtime reflects:

- chronic understaffing
- workload imbalance
- seasonal demand
- scheduling issues
- excessive sales targets

Do not implement a company-wide overtime policy based on this segment alone.

---

## Priority 2 — Investigate Job Level 1 Attrition

**Evidence:** Job Level 1 attrition is 26.34%, above the company baseline.

### Recommended action

Analyze Job Level 1 attrition by:

- department
- job role
- overtime
- tenure
- compensation
- job satisfaction

The objective is to identify whether elevated attrition is concentrated in particular organizational units.

---

## Priority 3 — Address Department-Specific Risk Patterns

Different departments show different risk profiles.

Sales shows high departmental attrition, while R&D contributes the largest share of total departures because of its workforce size.

### Recommended action

Use department-specific retention analysis rather than applying one universal intervention across the organization.

---

## Priority 4 — Review Compensation at Lower Salary Bands

**Evidence:** 68.78% of all departures come from employees earning up to $5k, with lower average income among leavers within this band.

### Recommended action

Conduct a targeted compensation and pay-progression review considering:

- tenure
- job level
- job role
- salary progression
- internal pay compression
- market competitiveness

---

## Priority 5 — Use Exposure as Well as Attrition Rate

High-rate segments should not automatically receive all retention resources.

### Recommended action

Create a retention-priority score incorporating:

- attrition rate
- number of employees lost
- share of total departures
- workforce size
- business criticality where available

This creates a more balanced decision framework.

---

## Priority 6 — Investigate Promotion Stagnation

The $10k–$15k salary band shows longer tenure and longer time since promotion among leavers.

### Recommended action

Review employees with extended periods since their last promotion and assess:

- career-path clarity
- internal mobility
- promotion availability
- role expansion
- manager support
- compensation progression

Use approximately four years as an **investigation threshold**, not as a proven causal cutoff.

---

