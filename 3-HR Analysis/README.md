# HR Attrition Analytics --- Executive Report

**Project:** HR Employee Attrition Analysis\
**Prepared by:** Mohamed Abdullah Ali --- Data Analyst\
**Tools:** Python, SQL, Power BI, DAX\
**Dataset size:** 1,470 employees\
**Primary objective:** Understand who is leaving, identify the strongest
observable attrition patterns, locate organizational risk, and translate
the findings into targeted retention priorities.

------------------------------------------------------------------------

## 1. Executive Overview

The workforce contains **1,470 employees**, of whom **237 have left**,
producing an overall attrition rate of **16.12%**. This baseline is used
throughout the analysis to distinguish normal variation from materially
elevated employee-risk segments.

The analysis is structured around three management questions:

1.  **Who is leaving?** --- demographic and workforce segmentation.
2.  **Why are they leaving?** --- work experience, workload, distance,
    compensation, and career progression patterns.
3.  **Where is the organizational risk?** --- departments, job roles,
    job levels, travel patterns, and concentration of actual leavers.

### Executive takeaways

-   **Early-career employees are the clearest demographic risk:**
    attrition reaches **35.77%** for employees aged 18--25 versus the
    16.12% company baseline.
-   **Single employees show elevated attrition:** **25.53%**,
    approximately twice the rate of married employees (**12.48%**).
-   **Overtime is a major observable risk signal:** attrition is
    **30.53%** among employees working overtime versus **10.44%** among
    those who do not.
-   **Job involvement has a strong monotonic relationship with
    attrition:** the rate falls from **33.73% at Low involvement** to
    **9.03% at Very High involvement**.
-   **Distance from home shows an upward pattern at the displayed
    distance bands:** the highest shown band reaches **22.14%**,
    compared with **13.55%** at the lowest band.
-   **The highest-risk department by displayed attrition rate is Sales
    at 20.63%**, followed by Human Resources at 19.05%; R&D is lower at
    13.84%.
-   **Sales Representative is the highest-risk displayed job role at
    39.76%.**
-   **Entry-level employees have the highest job-level attrition rate at
    26.34%.**
-   **Risk rate and organizational exposure are different:** Laboratory
    Technician has a 23.94% attrition rate but contributes **62
    leavers**, or **26.16% of all leavers**.
-   **The lowest salary band is the largest source of actual
    attrition:** employees earning up to \$5K account for **163
    leavers**, or **68.78% of all leavers**.

> **Important analytical distinction:** These findings identify
> statistical/observable associations in the dataset. They do not prove
> that a variable causes an employee to leave.

------------------------------------------------------------------------

## 2. Page 1 --- Who Is Leaving?

### 2.1 Age profile

  Age group     Attrition rate
  ----------- ----------------
  18--25                35.77%
  26--35                19.14%
  36--45                 9.19%
  46--55                11.50%
  55+                   17.02%

The age pattern is not a simple linear decline. Attrition is highest
among **18--25**, reaches its lowest point at **36--45**, and rises
again among employees aged **55+**.

This suggests that age should not be treated as one uniform retention
problem. The two elevated ends of the distribution may represent
different workforce situations and should be investigated separately.

### 2.2 Marital status

Single employees show a **25.53%** attrition rate compared with
**12.48%** for married employees and **10.09%** for divorced employees.

This is a meaningful segmentation signal, but it should be interpreted
as an association rather than a causal explanation. A useful next step
would be to cross-segment marital status with age, overtime, role, and
tenure.

### 2.3 Gender

The dashboard displays **588 female employees and 882 male employees**.
The visual is a workforce-composition chart rather than a
gender-specific attrition-rate comparison.

Therefore, this dashboard should **not** be used to claim that gender is
or is not a major attrition driver. A dedicated gender attrition-rate
measure would be required for that conclusion.

### 2.4 Education field

The highest displayed attrition rates are:

-   Human Resources: **25.93%**
-   Technical Degree: **24.24%**
-   Marketing: **22.01%**
-   Life Sciences: **14.69%**
-   Medical: **13.58%**
-   Other: **13.41%**

Education field is a useful segmentation variable, but its management
value increases when combined with department, job role, job level, and
compensation.

------------------------------------------------------------------------

## 3. Page 2 --- Why Are They Leaving?

### 3.1 Overtime

  Overtime     Attrition rate
  ---------- ----------------
  Yes                  30.53%
  No                   10.44%

The difference is substantial. Employees working overtime have an
attrition rate nearly three times that of employees who do not.

**Management implication:** Overtime should be investigated as a
workload and staffing signal, especially inside high-risk roles and
departments.

### 3.2 Job involvement

  Job involvement     Attrition rate
  ----------------- ----------------
  Low                         33.73%
  Medium                      18.93%
  High                        14.40%
  Very High                    9.03%

This is one of the clearest gradients in the dashboard. Attrition
declines consistently as job involvement increases.

**Management implication:** Employee involvement should be treated as an
important retention signal and investigated alongside manager
relationship, workload, career progression, and role design.

### 3.3 Distance from home

The displayed distance bands show:

-   0 km: **13.55%**
-   5 km: **17.49%**
-   10 km: **19.58%**
-   15 km: **19.58%**
-   20 km: **22.14%**

The pattern indicates higher attrition at greater displayed distances.

**Management implication:** Commute burden may be a relevant
employee-experience signal. It should be tested further against travel
frequency, department, job role, and work-life balance.

### 3.4 Work-life balance

The dashboard shows the strongest attrition at the **Bad**
work-life-balance level, at **31.25%**, while the displayed rates
decline toward the better categories.

This supports investigating workload, scheduling, overtime, and
managerial practices together rather than treating work-life balance as
an isolated survey variable.

### 3.5 Environment and job satisfaction

Lower satisfaction levels generally show higher displayed attrition
rates. For example, the overall job-satisfaction chart shows:

-   Low: **22.84%**
-   High: **16.52%**
-   Medium: **16.43%**
-   Very High: **11.33%**

The pattern is directionally consistent with the job-involvement
finding: weaker employee experience is associated with higher attrition.

------------------------------------------------------------------------

## 4. Compensation Segmentation --- Four Different Attrition Profiles

The salary filter was used to avoid treating compensation as one
homogeneous problem.

  --------------------------------------------------------------------------
  Salary band         Employees        Leavers Attrition rate   Share of all
                                                                     leavers
  -------------- -------------- -------------- -------------- --------------
  Up to \$5K                749            163         21.76%         68.78%

  \$5K--\$10K               440             49         11.14%         20.68%

  \$10K--\$15K              148             20         13.51%          8.44%

  \$15K+                    133              5          3.76%          2.11%
  --------------------------------------------------------------------------

### Up to \$5K --- largest exposure

This segment contributes **163 of the 237 leavers**. Within the band,
leavers have lower average monthly income than employees who stayed
(**\$2,827.83 vs. \$3,290.17**) and shorter average tenure (**3.32
vs. 5.06 years**).

This profile supports a targeted review of compensation, early-career
progression, and retention practices for lower-paid employees.

### \$5K--\$10K --- different signal

Attrition is lower at **11.14%**, while average monthly income among
leavers is slightly higher than among stayers (**\$7,150.35
vs. \$6,787.17**).

This means a blanket "increase salaries" response would be too
simplistic. Market competitiveness, role mobility, and career
opportunities should also be investigated.

### \$10K--\$15K --- tenure and promotion risk

Leavers have longer tenure (**13.80 vs. 11.58 years**) and more years
since promotion (**5.90 vs. 4.05 years**) than stayers.

This is consistent with a possible **career-progression /
promotion-stagnation signal**.

### \$15K+ --- low-rate, low-exposure segment

Only **5 employees** have left from this band, producing a **3.76%**
attrition rate and only **2.11%** of all leavers.

Because the number of leavers is small, this segment should not drive a
major company-wide intervention.

------------------------------------------------------------------------

## 5. Page 3 --- Where Is the Organizational Risk?

### 5.1 Department-level risk

  Department                 Attrition rate
  ------------------------ ----------------
  Sales                              20.63%
  Human Resources                    19.05%
  Research & Development             13.84%

Sales has the highest displayed departmental attrition rate.

However, rate alone is not enough. R&D has a much larger workforce and
therefore can generate substantial absolute attrition even with a lower
rate.

### 5.2 Job-role risk

The highest displayed job-role rates include:

  Job role                  Attrition rate
  ----------------------- ----------------
  Sales Representative              39.76%
  Laboratory Technician             23.94%
  Human Resources                   23.08%
  Sales Executive                   17.48%
  Research Scientist                16.10%

**Sales Representative** is the highest-risk role by rate.

### 5.3 Job-level risk

  Job level          Attrition rate
  ---------------- ----------------
  Entry Level                26.34%
  Senior Level               14.68%
  Mid Level                   9.74%
  Director Level              7.25%
  Manager Level               4.72%

The entry-level population has the highest attrition rate.

The appropriate response is not simply a company-wide entry-level
program; the role and department context must be considered.

### 5.4 Exposure versus rate

One of the most important analytical conclusions is the distinction
between **risk intensity** and **organizational exposure**.

-   Sales Representative has the highest displayed rate (**39.76%**).
-   Laboratory Technician has a lower rate (**23.94%**) but contributes
    **62 actual leavers**, representing **26.16% of all leavers**.
-   Research & Development contributes **56.12% of all leavers**,
    despite having a lower departmental attrition rate of **13.84%**,
    because it is the largest department in the dataset.

This means retention investment should consider both:

**Risk rate × workforce exposure**

rather than ranking segments by percentage alone.

### 5.5 Business travel

  Travel pattern        Attrition rate
  ------------------- ----------------
  Travel Frequently             24.91%
  Travel Rarely                 14.96%
  Non-Travel                     8.00%

Frequent travelers show substantially higher attrition.

This should be cross-checked with job role, department, overtime, and
work-life balance before being converted into a policy decision.

------------------------------------------------------------------------

## 6. Cross-Segment Risk

The dashboard analysis identifies particularly high-risk combinations
within the workforce.

### Sales Representative + Overtime

The combined segment reaches **66.7% attrition (n=24)**.

### Sales Representative + Frequent Travel

The combined segment reaches **65.2% attrition (n=23)**.

These are highly concentrated risk segments and are more actionable than
broad company-wide averages.

However, the sample sizes are small. The correct management
interpretation is:

> **These segments are high-priority risk signals that require
> operational validation, not proof of causality.**

------------------------------------------------------------------------

## 7. Priority Matrix

  --------------------------------------------------------------------------------
  Priority          Segment           Evidence          Recommended focus
  ----------------- ----------------- ----------------- --------------------------
  1                 Sales             66.7% attrition,  Workload, staffing,
                    Representatives   n=24              overtime root-cause review
                    with overtime                       

  2                 Sales             65.2% attrition,  Travel load, scheduling,
                    Representatives   n=23              role design
                    with frequent                       
                    travel                              

  3                 Up to \$5K salary 68.78% of all     Compensation +
                    band              leavers           early-career retention

  4                 Laboratory        62 leavers /      Exposure-focused retention
                    Technicians       26.16% of all     program
                                      leavers           

  5                 Entry-level       26.34% attrition  Department/role-specific
                    employees                           onboarding and progression

  6                 \$10K--\$15K      5.90 years since  Career-path and promotion
                    long-tenure       promotion among   review
                    employees         leavers           

  7                 Frequent          24.91% attrition  Travel burden and
                    travelers                           work-life review
  --------------------------------------------------------------------------------

------------------------------------------------------------------------

## 8. Strategic Recommendations

### 1. Launch a targeted Sales Representative workload review

Investigate overtime and travel within Sales Representative roles before
applying a company-wide intervention.

**Actions:** - Review overtime concentration by employee and manager. -
Compare staffing levels with workload. - Review travel frequency and
scheduling. - Establish role-specific retention targets.

### 2. Build department-specific entry-level retention plans

The entry-level problem should not be treated uniformly.

**Actions:** - Strengthen onboarding. - Establish 30/60/90-day
milestones. - Add mentoring for high-risk roles. - Review early-career
compensation and progression. - Monitor attrition by department and
role.

### 3. Prioritize retention by both rate and exposure

Create a retention score combining: - attrition rate, - number of
employees leaving, - share of all leavers, - workforce size.

This prevents small high-rate groups from automatically receiving more
resources than large groups generating greater organizational loss.

### 4. Review lower-paid employee retention

Because the Up to \$5K band contributes **68.78% of all leavers**, it
deserves a dedicated compensation and career review.

The intervention should not automatically be "raise salaries."
Compare: - salary versus tenure, - salary versus role, - promotion
history, - overtime, - job level, - department.

### 5. Address promotion stagnation

The \$10K--\$15K segment shows a distinctive pattern of longer tenure
and longer time since promotion among leavers.

**Actions:** - Identify employees with long promotion gaps. - Review
career paths. - Define advancement criteria. - Introduce structured
career conversations.

### 6. Investigate travel and work-life burden

Frequent travel and poor work-life balance are both associated with
higher attrition.

**Actions:** - Review travel frequency. - Identify roles with sustained
travel burden. - Evaluate scheduling flexibility. - Monitor overtime and
travel together.

------------------------------------------------------------------------

## 9. Management Monitoring Framework

The analysis should become a recurring HR monitoring process rather than
a one-time dashboard.

Recommended monthly/quarterly KPIs:

1.  Overall attrition rate
2.  Voluntary attrition rate, if available
3.  Attrition by department
4.  Attrition by job role
5.  Attrition by job level
6.  Attrition among new hires
7.  Overtime attrition rate
8.  Frequent-travel attrition rate
9.  Attrition by salary band
10. High-risk segment exposure
11. Number of leavers by segment
12. Share of total leavers by segment
13. Average tenure of leavers
14. Average years since last promotion among leavers

------------------------------------------------------------------------

## 10. Analytical Limitations

This project is an observational analysis. The dashboard identifies
**patterns and associations**, not causal relationships.

Important limitations:

-   The dataset does not establish why each employee actually left.
-   Some high-risk segments have small sample sizes.
-   Attrition rates should always be considered alongside segment
    population size.
-   Cross-sectional employee data limits direct time-series conclusions.
-   Gender on Page 1 is shown as workforce composition, not a gender
    attrition-rate comparison.
-   Factors such as management quality, external labor-market
    conditions, employee performance context, and personal circumstances
    are not fully captured.

Therefore, recommendations should be treated as **evidence-based
hypotheses for HR validation**, followed by targeted interventions and
monitoring.

------------------------------------------------------------------------

## 11. Final Executive Conclusion

The organization-wide **16.12% attrition rate** hides several distinct
retention problems.

The most important finding is that attrition is **concentrated rather
than uniform**:

-   young employees show high demographic risk,
-   overtime and low job involvement are strong employee-experience
    signals,
-   Sales and Sales Representative roles show elevated organizational
    risk,
-   entry-level employees have the highest job-level rate,
-   lower-paid employees represent the largest exposure of actual
    leavers,
-   and a smaller set of high-risk combinations---particularly Sales
    Representative with overtime or frequent travel---deserve immediate
    investigation.

The recommended strategy is therefore **targeted retention rather than a
single company-wide solution**.

Management should prioritize interventions where **high attrition rate,
meaningful workforce exposure, and actionable operational factors
overlap**.

------------------------------------------------------------------------

## Appendix --- Dashboard Structure

### Page 1 --- HR High-Attrition Employee Groups

Answers: **Who is leaving?**

Focus: - Age group - Marital status - Education field - Workforce
composition

### Page 2 --- Attrition Drivers & Employee Experience

Answers: **Why are they leaving?**

Focus: - Overtime - Job involvement - Distance from home - Work-life
balance - Environment satisfaction - Job satisfaction - Career
progression - Salary-band segmentation

### Page 3 --- Where Is the Organizational Risk?

Answers: **Where should management intervene?**

Focus: - Department - Job role - Job level - Business travel -
Organizational concentration - Risk rate versus exposure

------------------------------------------------------------------------

**Prepared by:** Mohamed Abdullah Ali\
**Role:** Data Analyst\
**Project:** HR Employee Attrition Analytics
