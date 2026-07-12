-- =====================================================================================
-- LOAD_DIM_PRODUCT.sql
-- Step 3 (continued): collapses STG_PRODUCT rows sharing a MATCH_KEY into one
-- DIM_PRODUCT row per real product, and records each branch's ACTUAL price in
-- PRODUCT_BRANCH_MAP (needed since price varies by branch even for one product).
--
-- DEPENDS ON: 01_tables_and_alters.sql, LOAD_STG_PRODUCT.sql having populated
-- STG_PRODUCT.
-- =====================================================================================

create or replace PROCEDURE LOAD_DIM_PRODUCT AS 
BEGIN
    -- DIM_PRODUCT.UNIT_PRICE is a REFERENCE price only (average across the branches
    -- that sell this product) — name/size/category come from one representative
    -- branch row (RN=1), same pattern as customers, but price is deliberately
    -- averaged rather than taken from a single "winning" branch, since every
    -- branch's price is equally real and none of them should be discarded.
    INSERT INTO DIM_PRODUCT (SOURCE_PRODUCT_ID, PRODUCT_NAME, UNIT_PRICE, PRODUCT_TYPE,
                              BOTTLE_SIZE_LITERS, PRODUCT_CATEGORY, MATCH_KEY)
    SELECT SOURCE_PRODUCT_ID, PRODUCT_NAME, REF_PRICE, PRODUCT_TYPE, BOTTLE_SIZE_LITERS,
           PRODUCT_CATEGORY, MATCH_KEY
    FROM (
        SELECT s.*,
               ROUND(AVG(s.UNIT_PRICE) OVER (PARTITION BY s.MATCH_KEY), 2) AS REF_PRICE,
               ROW_NUMBER() OVER (PARTITION BY s.MATCH_KEY ORDER BY s.SOURCE_BRANCH) AS RN
        FROM STG_PRODUCT s
        WHERE NOT EXISTS (SELECT 1 FROM DIM_PRODUCT d WHERE d.MATCH_KEY = s.MATCH_KEY)
    )
    WHERE RN = 1;

    -- Persist the ACTUAL price each branch charges (step 4/5 turnover math needs
    -- this, not the averaged reference price above). WHEN MATCHED also refreshes
    -- price on re-runs, since — unlike a customer's address — price can change.
    MERGE INTO PRODUCT_BRANCH_MAP m
    USING (
        SELECT s.SOURCE_BRANCH, s.SOURCE_PRODUCT_ID, d.PRODUCT_KEY, s.UNIT_PRICE
        FROM STG_PRODUCT s
        JOIN DIM_PRODUCT d ON d.MATCH_KEY = s.MATCH_KEY
    ) src
    ON (m.SOURCE_BRANCH = src.SOURCE_BRANCH AND m.SOURCE_PRODUCT_ID = src.SOURCE_PRODUCT_ID)
    WHEN MATCHED THEN
        UPDATE SET m.UNIT_PRICE = src.UNIT_PRICE
    WHEN NOT MATCHED THEN
        INSERT (SOURCE_BRANCH, SOURCE_PRODUCT_ID, PRODUCT_KEY, UNIT_PRICE)
        VALUES (src.SOURCE_BRANCH, src.SOURCE_PRODUCT_ID, src.PRODUCT_KEY, src.UNIT_PRICE);

    COMMIT;
END LOAD_DIM_PRODUCT;
