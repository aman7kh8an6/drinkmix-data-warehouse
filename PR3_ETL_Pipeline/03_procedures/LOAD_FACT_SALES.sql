-- =====================================================================================
-- LOAD_FACT_SALES.sql
-- Step 5: aggregates STG_SALES into FACT_SALES at the (customer, product, branch,
-- day) grain, converting unit quantity into liters (quantity * bottle size).
--
-- Requires DIM_BRANCH and DIM_TIME to already be populated (inner joins below) -
-- if either is empty, this procedure will silently produce zero fact rows.
--
-- DEPENDS ON: LOAD_DIM_BRANCH, LOAD_DIM_TIME, LOAD_STG_SALES, LOAD_DIM_CUSTOMER
-- and LOAD_DIM_PRODUCTS having all been RUN (not just compiled) already.
-- =====================================================================================

CREATE OR REPLACE PROCEDURE LOAD_FACT_SALES AS
BEGIN
    -- Step 5: sales volume in liters = unit quantity * bottle size. FACT_SALES grain
    -- is (customer, product, branch, day), so multiple order lines on the same day
    -- for the same customer/product/branch are summed here.
    MERGE INTO FACT_SALES f
    USING (
        SELECT cm.CUSTOMER_KEY,
               pm.PRODUCT_KEY,
               db.BRANCH_KEY,
               TO_NUMBER(TO_CHAR(TRUNC(s.SALE_DATE), 'YYYYMMDD')) AS TIME_KEY,
               SUM(s.QUANTITY_UNITS * dp.BOTTLE_SIZE_LITERS) AS QUANTITY_LITERS
        FROM STG_SALES s
        JOIN CUSTOMER_BRANCH_MAP cm ON cm.SOURCE_BRANCH = s.SOURCE_BRANCH
                                    AND cm.SOURCE_CUSTOMER_ID = s.SOURCE_CUSTOMER_ID
        JOIN PRODUCT_BRANCH_MAP  pm ON pm.SOURCE_BRANCH = s.SOURCE_BRANCH
                                    AND pm.SOURCE_PRODUCT_ID = s.SOURCE_PRODUCT_ID
        JOIN DIM_PRODUCT dp ON dp.PRODUCT_KEY = pm.PRODUCT_KEY
        JOIN DIM_BRANCH  db ON db.BRANCH_NAME = s.SOURCE_BRANCH
        GROUP BY cm.CUSTOMER_KEY, pm.PRODUCT_KEY, db.BRANCH_KEY, TRUNC(s.SALE_DATE)
    ) src
    ON (f.CUSTOMER_KEY = src.CUSTOMER_KEY AND f.PRODUCT_KEY = src.PRODUCT_KEY
        AND f.BRANCH_KEY = src.BRANCH_KEY AND f.TIME_KEY = src.TIME_KEY)
    WHEN MATCHED THEN
        UPDATE SET f.QUANTITY_LITERS = src.QUANTITY_LITERS
    WHEN NOT MATCHED THEN
        INSERT (CUSTOMER_KEY, PRODUCT_KEY, BRANCH_KEY, TIME_KEY, QUANTITY_LITERS)
        VALUES (src.CUSTOMER_KEY, src.PRODUCT_KEY, src.BRANCH_KEY, src.TIME_KEY, src.QUANTITY_LITERS);

    COMMIT;
END LOAD_FACT_SALES;