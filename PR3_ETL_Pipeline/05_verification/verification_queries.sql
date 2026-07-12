-- =====================================================================================
-- 01_verification_queries.sql
-- Run these after RUN_FULL_ETL to confirm the load worked as expected.
-- =====================================================================================

-- Total branch-local customer rows read vs. unique real customers found (dedup effect)
SELECT COUNT(*) AS TOTAL_BRANCH_CUSTOMER_ROWS FROM STG_CUSTOMER;
SELECT COUNT(*) AS UNIQUE_CUSTOMERS         FROM DIM_CUSTOMER;
SELECT COUNT(*) AS MAPPING_ROWS             FROM CUSTOMER_BRANCH_MAP; -- should equal TOTAL_BRANCH_CUSTOMER_ROWS

-- Any sales lines that still failed to parse a quantity (should be empty - if not,
-- there's a spelled-out word or format PARSE_QUANTITY doesn't recognize yet)
SELECT * FROM STG_SALES WHERE QUANTITY_UNITS IS NULL;

-- Product dedup: expect exactly 29 (matched on shared SOURCE_PRODUCT_ID)
SELECT COUNT(*) AS TOTAL_BRANCH_PRODUCT_ROWS FROM STG_PRODUCT;
SELECT COUNT(*) AS UNIQUE_PRODUCTS           FROM DIM_PRODUCT;

-- Any branch product rows that didn't collapse into a DIM_PRODUCT row (should be empty)
SELECT SOURCE_BRANCH, SOURCE_PRODUCT_ID, PRODUCT_NAME
FROM STG_PRODUCT s
WHERE MATCH_KEY NOT IN (SELECT MATCH_KEY FROM DIM_PRODUCT)
ORDER BY TO_NUMBER(SOURCE_PRODUCT_ID), SOURCE_BRANCH;

-- Eyeball where branches disagree on the product NAME for the same ID (translation/
-- spelling differences like "Apple-Peach" vs "Apfel-Pfirsich") - informational only,
-- since matching is done on ID, not name, this no longer affects dedup correctness
SELECT SOURCE_PRODUCT_ID,
       LISTAGG(SOURCE_BRANCH || ':' || PRODUCT_NAME, ' | ') WITHIN GROUP (ORDER BY SOURCE_BRANCH) AS NAMES_BY_BRANCH
FROM STG_PRODUCT
GROUP BY SOURCE_PRODUCT_ID
HAVING COUNT(DISTINCT UPPER(PRODUCT_NAME)) > 1
ORDER BY TO_NUMBER(SOURCE_PRODUCT_ID);

-- Fact table sanity: row count, total liters, total turnover, age group distribution
SELECT COUNT(*) AS FACT_ROWS, SUM(QUANTITY_LITERS) AS TOTAL_LITERS FROM FACT_SALES;
SELECT SUM(TURNOVER) AS TOTAL_TURNOVER FROM V_FACT_SALES_TURNOVER;
SELECT AGE_GROUP, COUNT(*) FROM DIM_CUSTOMER GROUP BY AGE_GROUP ORDER BY AGE_GROUP;

-- Confirm price really does vary by branch, and see DIM_PRODUCT's averaged
-- reference price next to what each branch actually charges
SELECT dp.PRODUCT_NAME, dp.UNIT_PRICE AS REFERENCE_PRICE,
       pbm.SOURCE_BRANCH, pbm.UNIT_PRICE AS BRANCH_PRICE
FROM DIM_PRODUCT dp
JOIN PRODUCT_BRANCH_MAP pbm ON pbm.PRODUCT_KEY = dp.PRODUCT_KEY
ORDER BY dp.PRODUCT_NAME, pbm.SOURCE_BRANCH;
