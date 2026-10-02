/*
============================================================
Sales Data Warehouse
KPI Validation
============================================================
Purpose:
Validate the key business KPIs used in the Power BI dashboard.
============================================================
*/

-- 1. Overall Sales KPIs
SELECT
    SUM(sales_amount) AS Total_Sales,
    COUNT(DISTINCT order_number) AS Total_Orders,
    SUM(quantity) AS Total_Quantity,
    SUM(sales_amount) / NULLIF(COUNT(DISTINCT order_number), 0)
        AS Average_Order_Value
FROM silver.fact_sales;


-- 2. Sales by Product Line
SELECT
    p.product_line,
    SUM(f.sales_amount) AS Total_Sales
FROM silver.fact_sales f
LEFT JOIN silver.dim_product p
    ON f.product_key = p.product_key
GROUP BY p.product_line
ORDER BY Total_Sales DESC;


-- 3. Sales by Gender
SELECT
    c.gender,
    SUM(f.sales_amount) AS Total_Sales
FROM silver.fact_sales f
LEFT JOIN silver.dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY c.gender
ORDER BY Total_Sales DESC;


-- 4. Power BI AOV Reconciliation
SELECT
    SUM(sales_amount) /
        NULLIF(COUNT(DISTINCT order_number), 0) AS True_AOV,

    (SELECT AVG(average_order_value)
     FROM gold.customer_sales) AS Gold_AOV;