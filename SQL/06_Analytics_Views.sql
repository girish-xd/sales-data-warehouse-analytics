/*
============================================================
Sales Data Warehouse
Analytics Views
============================================================
Purpose:
Analytical views used for KPI reporting, sales analysis,
and Power BI dashboarding.
============================================================
*/


-- =========================================================
-- 1. Sales Summary View
-- =========================================================

CREATE OR ALTER VIEW silver.vw_sales_summary
AS
SELECT
    f.sales_key,
    f.order_number,

    -- Date
    f.order_date,
    d.year,
    d.quarter,
    d.month,
    d.month_name,

    -- Product
    f.product_key,
    p.product_code,
    p.product_name,

    -- Customer
    f.customer_key,
    c.customer_id,
    c.gender,

    -- Sales Metrics
    f.sales_amount,
    f.quantity,
    f.unit_price

FROM silver.fact_sales f

LEFT JOIN silver.dim_date d
    ON f.order_date = d.full_date

LEFT JOIN silver.dim_product p
    ON f.product_key = p.product_key

LEFT JOIN silver.dim_customer c
    ON f.customer_key = c.customer_key;


-- =========================================================
-- 2. Sales KPI View
-- =========================================================

CREATE OR ALTER VIEW silver.vw_sales_kpi
AS
SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    AVG(unit_price) AS average_unit_price,

    CAST(
        SUM(sales_amount) * 1.0
        / NULLIF(COUNT(DISTINCT order_number), 0)
        AS DECIMAL(18,2)
    ) AS average_order_value

FROM silver.vw_sales_summary;


-- =========================================================
-- 3. Data Quality Issues View
-- =========================================================

CREATE OR ALTER VIEW silver.vw_data_quality_issues
AS

SELECT
    'Missing Order Dates' AS issue_type,
    missing_order_dates AS issue_count
FROM silver.vw_data_quality_summary

UNION ALL

SELECT
    'Negative Unit Prices',
    negative_unit_prices
FROM silver.vw_data_quality_summary

UNION ALL

SELECT
    'Negative Sales',
    negative_sales
FROM silver.vw_data_quality_summary

UNION ALL

SELECT
    'Zero Sales',
    zero_sales
FROM silver.vw_data_quality_summary

UNION ALL

SELECT
    'Invalid Quantities',
    invalid_quantities
FROM silver.vw_data_quality_summary

UNION ALL

SELECT
    'Amount Mismatches',
    amount_mismatch_rows
FROM silver.vw_data_quality_summary;