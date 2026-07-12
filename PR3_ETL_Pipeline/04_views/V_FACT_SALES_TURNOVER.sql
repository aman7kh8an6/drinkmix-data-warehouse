-- =====================================================================================
-- V_FACT_SALES_TURNOVER.sql
-- Step 4: turnover (sales volume in money), computed on read rather than persisted
-- on FACT_SALES. units = liters / bottle_size (reverses step 5's multiplication),
-- turnover = units * the price the SELLING BRANCH actually charged (from
-- PRODUCT_BRANCH_MAP), not DIM_PRODUCT's averaged reference price - the same
-- product can turn over a different amount per branch if that branch prices it
-- differently.
--
-- DEPENDS ON: FACT_SALES, DIM_PRODUCT, DIM_BRANCH, PRODUCT_BRANCH_MAP.
-- =====================================================================================

CREATE OR REPLACE VIEW V_FACT_SALES_TURNOVER AS
SELECT f.CUSTOMER_KEY, f.PRODUCT_KEY, f.BRANCH_KEY, f.TIME_KEY,
       f.QUANTITY_LITERS,
       pbm.UNIT_PRICE AS BRANCH_UNIT_PRICE,
       ROUND(f.QUANTITY_LITERS / dp.BOTTLE_SIZE_LITERS * pbm.UNIT_PRICE, 2) AS TURNOVER
FROM FACT_SALES f
JOIN DIM_PRODUCT dp  ON dp.PRODUCT_KEY = f.PRODUCT_KEY
JOIN DIM_BRANCH  db  ON db.BRANCH_KEY  = f.BRANCH_KEY
JOIN PRODUCT_BRANCH_MAP pbm ON pbm.PRODUCT_KEY = f.PRODUCT_KEY
                            AND pbm.SOURCE_BRANCH = db.BRANCH_NAME;
