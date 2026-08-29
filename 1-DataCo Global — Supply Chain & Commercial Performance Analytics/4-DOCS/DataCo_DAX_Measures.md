

## 1. Base measures

### Volume & scale
```dax
Total Orders = DISTINCTCOUNT('Fact_OrderItems'[Order Id])

Total Order Items = COUNTROWS('Fact_OrderItems')

Total Customers = DISTINCTCOUNT('Fact_OrderItems'[Customer Id])

Total Products Sold = DISTINCTCOUNT('Fact_OrderItems'[Product Card Id])

Total Quantity Sold = SUM('Fact_OrderItems'[Order Item Quantity])
```

### Sales & profit
```dax
Total Sales Before Discount = SUM('Fact_OrderItems'[Order Total Price Before Discount])

Total Sales After Discount = SUM('Fact_OrderItems'[Order Total Price After Discount])

Total Profit = SUM('Fact_OrderItems'[Benefit per order])

Avg Order Value = DIVIDE([Total Sales], [Total Orders])

Profit Margin % = DIVIDE([Total Profit], [Total Sales After Discount])

Avg Profit Ratio = AVERAGE('Fact_OrderItems'[Order Item Profit Ratio])

Sales % of Total = DIVIDE([Total Sales After Discount], CALCULATE([Total Sales After Discount], ALL('Dim_Product'), ALL('Dim_Location'), ALL('Dim_Customer')))

Profit % of Total = DIVIDE([Total Profit], CALCULATE([Total Profit], ALL('Dim_Product'), ALL('Dim_Location'), ALL('Dim_Customer')))
```

### Discount
```dax
Total Discount = SUM('Fact_OrderItems'[Order Item Discount])

Avg Discount Rate = AVERAGE('Fact_OrderItems'[Order Item Discount Rate])

Discount as % of Sales = DIVIDE([Total Discount], [Total Sales])
```

### Delivery & shipping
```dax
Late Delivery Orders = CALCULATE([Total Orders], 'Fact_OrderItems'[Late_delivery_risk] = 1)

Late Delivery % = DIVIDE([Late Delivery Orders], [Total Orders])

On-Time Delivery % = 1 - [Late Delivery %]

Avg Days Shipping (Real) = AVERAGE('Fact_OrderItems'[Days for shipping (real)])

Avg Days Shipping (Scheduled) = AVERAGE('Fact_OrderItems'[Days for shipment (scheduled)])

Avg Shipping Gap (Days) = [Avg Days Shipping (Real)] - [Avg Days Shipping (Scheduled)]
```

---

## 2. Time-intelligence measures

Requires `Dim_Date` marked as a date table.

```dax
PY(Previous Year) : SALES at jan 2025: $2000 jan 2024: $2500
YoY(Year Over Year) : 
2025 Sales = $120,000
2024 Sales = $100,000
Difference = 120,000 - 100,000 = 20,000
20,000 / 100,000 = 0.20 = 20%
Sales YoY = +20% 
+20% → Growth
0%   → No change
-20% → Decline

Sales PY = CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Dim_Date'[Date]))
Sales YoY % = DIVIDE([Total Sales] - [Sales PY], [Sales PY])

2025 Profit = $30,000
2024 Profit = $25,000
Profit PY = $25,000
30,000 - 25,000 = 5,000
5,000 / 25,000 = 20%
Sales:  +20%
Profit: -10%

Profit PY = CALCULATE([Total Profit], SAMEPERIODLASTYEAR('Dim_Date'[Date]))
Profit YoY % = DIVIDE([Total Profit] - [Profit PY], [Profit PY])

Orders 2025 = 8,000
Orders 2024 = 6,500
Orders PY = 6,500
8,000 - 6,500 = 1,500
1,500 / 6,500 = 23.08%
Orders increased by 23.08%.

Orders PY = CALCULATE([Total Orders], SAMEPERIODLASTYEAR('Dim_Date'[Date]))
Orders YoY % = DIVIDE([Total Orders] - [Orders PY], [Orders PY])

Customers 2025 = 5,000
Customers 2024 = 4,000
Customers PY = 4,000
5,000 - 4,000 = 1,000
1,000 / 4,000 = 25%
Customer base grew 25%.

Customers PY = CALCULATE([Total Customers], SAMEPERIODLASTYEAR('Dim_Date'[Date]))
Customers YoY % = DIVIDE([Total Customers] - [Customers PY], [Customers PY])

2025 Late Delivery = 14%
2024 Late Delivery = 10%
Late Delivery % PY = 10%
14 / 10 = 1.4
2025 = 14%
2024 = 10%
14% - 10% = +4 percentage points
Late delivery rate increased by 4 percentage points.

Late Delivery % PY = CALCULATE([Late Delivery %], SAMEPERIODLASTYEAR('Dim_Date'[Date]))
Late Delivery % Change = [Late Delivery %] - [Late Delivery % PY]


MTD = Month To Date
مثلاً اليوم:
March 15, 2025
والـ Sales:
Mar 1 → Mar 15 = $45,000
MTD Sales = $45,000
MTD = entire March Sales

MTD Sales = TOTALMTD([Total Sales], 'Dim_Date'[Date])

QTD = Quarter To Date
يعني:

Sales من بداية الـ Quarter حتى التاريخ الحالي.

مثلاً أنت في:

May 15, 2025

May موجود داخل:
Q2
April
May
June
April 1 → May 15
April Sales = $40k
May 1-15 = $20k
QTD Sales = $60k

QTD Sales = TOTALQTD([Total Sales], 'Dim_Date'[Date])
YTD = Year To Date

يعني:

Sales من January 1 حتى التاريخ الحالي.

مثلاً:

August 10, 2025
Jan 1 → Aug 10
Jan = 10k
Feb = 12k
Mar = 15k
...
Aug 1-10 = 4k
YTD Sales = $125,000
YTD Sales = TOTALYTD([Total Sales], 'Dim_Date'[Date])



ده مختلف عن YoY.

هنا إحنا بنقارن:

Current Month vs Previous Month

وليس:

Current Year vs Previous Year.
| Month    | Sales |
| -------- | ----: |
| January  |  $50k |
| February |  $55k |
| March    |  $52k |
| April    |  $52k |
لو أنت واقف على March:

CurrentPeriod = $52k
PriorPeriod = $55k
52k < 55k
Declining
لو April:
CurrentPeriod = $52k
PriorPeriod = $52k
Stable
CurrentPeriod = $60k
PriorPeriod = $52k
Growing
Sales Trend Direction =
VAR CurrentPeriod = [Total Sales]
VAR PriorPeriod = CALCULATE([Total Sales], DATEADD('Dim_Date'[Date], -1, MONTH))
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(PriorPeriod), "N/A",
        CurrentPeriod > PriorPeriod, "Growing",
        CurrentPeriod < PriorPeriod, "Declining",
        "Stable"
    )
```
| Metric                     | يقيس ماذا؟                                      |
| -------------------------- | ----------------------------------------------- |
| **Sales PY**               | Sales لنفس الفترة السنة الماضية                 |
| **Sales YoY %**            | نمو Sales مقابل السنة الماضية                   |
| **Profit PY**              | Profit لنفس الفترة السنة الماضية                |
| **Profit YoY %**           | نمو Profit مقابل السنة الماضية                  |
| **Orders PY**              | عدد Orders السنة الماضية لنفس الفترة            |
| **Orders YoY %**           | نمو عدد Orders                                  |
| **Customers PY**           | عدد العملاء في نفس الفترة السنة الماضية         |
| **Customers YoY %**        | نمو قاعدة العملاء                               |
| **Late Delivery % PY**     | Late Delivery Rate السنة الماضية                |
| **Late Delivery % Change** | الفرق في الـ rate بالـ percentage points        |
| **MTD Sales**              | Sales منذ بداية الشهر                           |
| **QTD Sales**              | Sales منذ بداية الـ Quarter                     |
| **YTD Sales**              | Sales منذ بداية السنة                           |
| **Sales Trend Direction**  | هل Sales تتحرك لأعلى/أسفل مقارنة بالشهر السابق؟ |
---