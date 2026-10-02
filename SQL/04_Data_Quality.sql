/*
============================================================
Sales Data Warehouse
Data Quality Validation
============================================================
Purpose:
Validate the Silver fact table for nulls, invalid values,
financial inconsistencies, and data integrity issues.
============================================================
*/

-- 1. Overall Data Quality Summary
SELECT *
FROM silver.vw_data_quality_summary;


-- 2. Product Referential Integrity
SELECT
    COUNT(*) AS Orphan_Product_Key_Rows
FROM silver.fact_sales f
LEFT JOIN silver.dim_product p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


-- 3. Customer Referential Integrity
SELECT
    COUNT(*) AS Orphan_Customer_Key_Rows
FROM silver.fact_sales f
LEFT JOIN silver.dim_customer c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


-- 4. Date Referential Integrity
SELECT
    COUNT(*) AS Orphan_Date_Rows
FROM silver.fact_sales f
LEFT JOIN silver.dim_date d
    ON f.order_date = d.full_date
WHERE f.order_date IS NOT NULL
  AND d.full_date IS NULL;


-- 5. Unknown / Unmatched Product Records
SELECT
    COUNT(*) AS Unknown_Product_Rows,
    SUM(sales_amount) AS Unknown_Product_Sales
FROM silver.fact_sales
WHERE product_key = 0;


-- 6. Missing Order Dates
SELECT
    COUNT(*) AS Missing_Order_Date_Rows,
    SUM(sales_amount) AS Missing_Order_Date_Sales
FROM silver.fact_sales
WHERE order_date IS NULL;


-- 7. Financial Data Quality Checks
SELECT
    SUM(CASE WHEN unit_price < 0 THEN 1 ELSE 0 END)
        AS Negative_Unit_Price_Rows,

    SUM(CASE WHEN sales_amount < 0 THEN 1 ELSE 0 END)
        AS Negative_Sales_Rows,

    SUM(CASE WHEN sales_amount = 0 THEN 1 ELSE 0 END)
        AS Zero_Sales_Rows,

    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END)
        AS Invalid_Quantity_Rows
FROM silver.fact_sales;


-- 8. Sales Amount Consistency
SELECT
    COUNT(*) AS Amount_Mismatch_Rows
FROM silver.fact_sales
WHERE sales_amount IS NOT NULL
  AND quantity IS NOT NULL
  AND unit_price IS NOT NULL
  AND ABS(sales_amount - (quantity * unit_price)) > 0.01;