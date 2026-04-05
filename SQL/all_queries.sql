
-- PROJECT 1: E-Commerce Revenue Analysis
-- Author : Lakumarapu Jyothiramyi
-- Dataset : Indian E-Commerce Sales (Kaggle - Ben Roshan)
-- ============================================================

-- ── FILE 1: FACT TABLE — Orders joined with Order Details ──────────────────
-- 01_fact_orders.sql
SELECT
    o.[Order ID]          AS OrderID,
    o.[Order Date]        AS OrderDate,
    o.[CustomerName]      AS CustomerName,
    o.[State]             AS State,
    o.[City]              AS City,
    d.[Amount]            AS SalesAmount,
    d.[Profit]            AS Profit,
    d.[Quantity]          AS Quantity,
    d.[Category]          AS Category,
    d.[Sub-Category]      AS SubCategory
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d
    ON o.[Order ID] = d.[Order ID]
ORDER BY o.[Order Date] ASC;


-- ── FILE 2: DIM CUSTOMER ───────────────────────────────────────────────────
-- 02_dim_customer.sql
SELECT DISTINCT
    [CustomerName]  AS CustomerName,
    [State]         AS State,
    [City]          AS City
FROM [List_of_Orders]
ORDER BY [CustomerName] ASC;


-- ── FILE 3: DIM PRODUCT ────────────────────────────────────────────────────
-- 03_dim_product.sql
SELECT DISTINCT
    [Category]      AS Category,
    [Sub-Category]  AS SubCategory
FROM [Order_Details]
ORDER BY [Category] ASC, [Sub-Category] ASC;


-- ── FILE 4: DIM CALENDAR ───────────────────────────────────────────────────
-- 04_dim_calendar.sql
SELECT DISTINCT
    [Order Date]                              AS FullDate,
    DAY([Order Date])                         AS DayNo,
    MONTH([Order Date])                       AS MonthNo,
    FORMAT([Order Date], 'MMM')               AS MonthShort,
    FORMAT([Order Date], 'MMMM')              AS MonthName,
    DATEPART(QUARTER, [Order Date])           AS Quarter,
    YEAR([Order Date])                        AS Year
FROM [List_of_Orders]
ORDER BY [Order Date] ASC;


-- ── FILE 5: BUSINESS QUERIES ───────────────────────────────────────────────
-- 05_business_queries.sql

-- Q1: Overall Business Summary
SELECT
    COUNT(DISTINCT o.[Order ID])        AS TotalOrders,
    COUNT(DISTINCT o.[CustomerName])    AS UniqueCustomers,
    COUNT(DISTINCT o.[State])           AS StatesReached,
    SUM(d.[Amount])                     AS TotalRevenue,
    SUM(d.[Profit])                     AS TotalProfit,
    SUM(d.[Quantity])                   AS TotalUnits,
    ROUND(SUM(d.[Profit]) * 100.0
        / NULLIF(SUM(d.[Amount]), 0), 2) AS MarginPct
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d ON o.[Order ID] = d.[Order ID];

-- Q2: Revenue and Profit by Category
SELECT
    d.[Category],
    COUNT(DISTINCT o.[Order ID])        AS TotalOrders,
    SUM(d.[Amount])                     AS TotalRevenue,
    SUM(d.[Profit])                     AS TotalProfit,
    ROUND(SUM(d.[Profit]) * 100.0
        / NULLIF(SUM(d.[Amount]), 0), 2) AS MarginPct,
    SUM(d.[Quantity])                   AS TotalUnits
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d ON o.[Order ID] = d.[Order ID]
GROUP BY d.[Category]
ORDER BY TotalRevenue DESC;

-- Q3: Top 10 States by Revenue
SELECT TOP 10
    o.[State],
    COUNT(DISTINCT o.[Order ID])        AS TotalOrders,
    COUNT(DISTINCT o.[CustomerName])    AS UniqueCustomers,
    SUM(d.[Amount])                     AS TotalRevenue,
    SUM(d.[Profit])                     AS TotalProfit
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d ON o.[Order ID] = d.[Order ID]
GROUP BY o.[State]
ORDER BY TotalRevenue DESC;

-- Q4: Monthly Revenue with MoM Growth
WITH monthly AS (
    SELECT
        YEAR(CONVERT(DATE, o.[Order Date], 103))   AS Yr,
        MONTH(CONVERT(DATE, o.[Order Date], 103))  AS Mo,
        FORMAT(CONVERT(DATE, o.[Order Date], 103), 'MMM-yyyy') AS Label,
        SUM(d.[Amount])  AS Revenue,
        SUM(d.[Profit])  AS Profit
    FROM [List_of_Orders] AS o
    INNER JOIN [Order_Details] AS d ON o.[Order ID] = d.[Order ID]
    GROUP BY
        YEAR(CONVERT(DATE, o.[Order Date], 103)),
        MONTH(CONVERT(DATE, o.[Order Date], 103)),
        FORMAT(CONVERT(DATE, o.[Order Date], 103), 'MMM-yyyy')
)
SELECT
    Label, Revenue, Profit,
    LAG(Revenue) OVER (ORDER BY Yr, Mo) AS PrevRevenue,
    ROUND((Revenue - LAG(Revenue) OVER (ORDER BY Yr, Mo)) * 100.0
        / NULLIF(LAG(Revenue) OVER (ORDER BY Yr, Mo), 0), 2) AS MoMGrowthPct
FROM monthly ORDER BY Yr, Mo;

-- Q5: Top 10 Customers by Revenue
SELECT TOP 10
    o.[CustomerName],
    o.[State],
    o.[City],
    COUNT(DISTINCT o.[Order ID])    AS TotalOrders,
    SUM(d.[Amount])                 AS TotalRevenue,
    SUM(d.[Profit])                 AS TotalProfit,
    RANK() OVER (ORDER BY SUM(d.[Amount]) DESC) AS RevenueRank
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d ON o.[Order ID] = d.[Order ID]
GROUP BY o.[CustomerName], o.[State], o.[City]
ORDER BY TotalRevenue DESC;

-- Q6: Sub-Category Profitability
SELECT
    d.[Category],
    d.[Sub-Category],
    SUM(d.[Amount])     AS TotalRevenue,
    SUM(d.[Profit])     AS TotalProfit,
    SUM(d.[Quantity])   AS TotalUnits,
    CASE
        WHEN SUM(d.[Profit]) > 5000  THEN 'High Performer'
        WHEN SUM(d.[Profit]) > 0     THEN 'Moderate'
        ELSE                              'Loss Making'
    END                 AS PerformanceTag
FROM [Order_Details] AS d
GROUP BY d.[Category], d.[Sub-Category]
ORDER BY TotalProfit DESC;

-- Q7: Sales vs Target by Category
SELECT
    t.[Category],
    t.[Month of Order Date]          AS TargetMonth,
    t.[Target]                       AS SalesTarget,
    COALESCE(SUM(d.[Amount]), 0)     AS ActualSales,
    COALESCE(SUM(d.[Amount]), 0) - t.[Target] AS Variance,
    CASE WHEN COALESCE(SUM(d.[Amount]), 0) >= t.[Target]
         THEN 'Met Target' ELSE 'Below Target' END AS Status
FROM [Sales_Target] AS t
LEFT JOIN [Order_Details] AS d ON d.[Category] = t.[Category]
GROUP BY t.[Category], t.[Month of Order Date], t.[Target]
ORDER BY t.[Category], t.[Month of Order Date];

-- Q8: Quarterly Performance
SELECT
    YEAR(CONVERT(DATE, o.[Order Date], 103))   AS Year,
    'Q' + CAST(CEILING(
        MONTH(CONVERT(DATE, o.[Order Date], 103)) / 3.0
    ) AS VARCHAR)                              AS Quarter,
    SUM(d.[Amount])                            AS Revenue,
    SUM(d.[Profit])                            AS Profit,
    COUNT(DISTINCT o.[Order ID])               AS Orders
FROM [List_of_Orders] AS o
INNER JOIN [Order_Details] AS d ON o.[Order ID] = d.[Order ID]
GROUP BY
    YEAR(CONVERT(DATE, o.[Order Date], 103)),
    CEILING(MONTH(CONVERT(DATE, o.[Order Date], 103)) / 3.0)
ORDER BY Year, Quarter;
