# 🛒 E-Commerce Revenue Analysis — SQL & Power BI & Looker Studio

> End-to-end Indian e-commerce sales analysis covering 501 orders worth ₹4.31 Lakhs across 3 product categories and 20+ Indian states.

---

## 📌 Project Overview

| Field | Details |
|-------|---------|
| Domain | E-Commerce / Retail Analytics |
| Tools | SQL · Excel · Power BI|
| Dataset | Indian E-Commerce Sales — Kaggle (Ben Roshan) |
| Period | April 2018 – March 2019 |
| Role | Data Analyst |

---

## 🎯 Business Problem

An Indian e-commerce company was using static Excel reports. Leadership needed:
- Which product categories drive the most revenue
- State-wise and city-wise sales performance
- Monthly revenue vs target tracking
- Top customers for retention focus

---

## 📁 Folder Structure

```
p1_ecommerce/
├── data/
│   ├── List_of_Orders.csv
│   ├── Order_Details.csv
│   └── Sales_Target.csv
├── sql/
│   ├── 01_fact_orders.sql
│   ├── 02_dim_customer.sql
│   ├── 03_dim_product.sql
│   ├── 04_dim_calendar.sql
│   └── 05_business_queries.sql
├── dashboard/
│   └── Ecommerce_Dashboard.pbix
└── README.md
```

---

## 🔍 Key SQL Queries

```sql
-- Revenue and Profit by Category
SELECT
    d.[Category],
    COUNT(DISTINCT o.[Order ID])   AS TotalOrders,
    SUM(d.[Amount])                AS TotalRevenue,
    SUM(d.[Profit])                AS TotalProfit,
    ROUND(SUM(d.[Profit]) * 100.0
        / NULLIF(SUM(d.[Amount]), 0), 2) AS MarginPct
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d
    ON o.[Order ID] = d.[Order ID]
GROUP BY d.[Category]
ORDER BY TotalRevenue DESC;

-- Top 10 Customers
SELECT TOP 10
    o.[CustomerName],
    o.[State],
    SUM(d.[Amount])  AS Revenue,
    SUM(d.[Profit])  AS Profit,
    RANK() OVER (ORDER BY SUM(d.[Amount]) DESC) AS Rnk
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d
    ON o.[Order ID] = d.[Order ID]
GROUP BY o.[CustomerName], o.[State]
ORDER BY Revenue DESC;

-- Monthly Revenue with MoM Growth
WITH monthly AS (
    SELECT
        FORMAT(CONVERT(DATE, o.[Order Date], 103), 'yyyy-MM') AS YM,
        SUM(d.[Amount]) AS Revenue
    FROM [List_of_Orders] AS o
    INNER JOIN [Order_Details] AS d ON o.[Order ID] = d.[Order ID]
    GROUP BY FORMAT(CONVERT(DATE, o.[Order Date], 103), 'yyyy-MM')
)
SELECT
    YM,
    Revenue,
    LAG(Revenue) OVER (ORDER BY YM) AS PrevRevenue,
    ROUND((Revenue - LAG(Revenue) OVER (ORDER BY YM)) * 100.0
        / NULLIF(LAG(Revenue) OVER (ORDER BY YM), 0), 2) AS MoMGrowth
FROM monthly ORDER BY YM;
```

---

## 💡 Key Insights

| # | Insight | Action |
|---|---------|--------|
| 1 | Madhya Pradesh + Maharashtra = 46% of revenue | Focus marketing here |
| 2 | Electronics leads revenue (38.3%) | Increase inventory |
| 3 | Clothing has best profit margin (8.0%) | Promote Clothing |
| 4 | July = lowest month (₹12,966) | Investigate seasonality |
| 5 | Top 10 customers = 21% of revenue | Build loyalty program |

---

## 👤 About Me

**[Lakumarapu Jyothirmayi]** — Data Analyst | SQL · Power BI · Python · Excel
LinkedIn: [https://www.linkedin.com/in/jyothirmayi-lakumarapu-88a96a3ab/]
Email: [jyothirmayilakumarapu@gmail.com]

*Dataset: Indian E-Commerce Sales Data — Kaggle (Ben Roshan)*
