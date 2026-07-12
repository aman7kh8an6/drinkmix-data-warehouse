-- =====================================================================================
-- LOAD_STG_SALES.sql
-- Reads the raw order lines from all three branches into a common shape
-- (STG_SALES), parsing each branch's AMOUNT/quantity field defensively.
--
-- DEPENDS ON: 01_tables_and_alters.sql, PARSE_QUANTITY.sql (and transitively
-- CLEAN_NUMBER.sql).
-- =====================================================================================

CREATE OR REPLACE PROCEDURE LOAD_STG_SALES AS
BEGIN
    DELETE FROM STG_SALES;

    -- Branch 1: ORDER table holds the transaction line directly (AMOUNT = unit qty).
    -- PARSE_QUANTITY instead of a plain TO_NUMBER/TRIM, since Branch 2's equivalent
    -- column is confirmed to spell some quantities out as words ('two','three','four')
    -- rather than digits - using the same defensive parser here in case Branch 1 ever
    -- has the same issue (it didn't in the current data, but the column shape is the
    -- same class of free-text field).
    INSERT INTO STG_SALES (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, SOURCE_PRODUCT_ID, SALE_DATE, QUANTITY_UNITS)
    SELECT 'BRANCH_1', TO_CHAR(CSTMR), TO_CHAR(PRO), "DATE", PARSE_QUANTITY(AMOUNT)
    FROM DWT_BRANCH_1."ORDER";

    -- Branch 2: BUYS table holds the transaction line directly. AMOUNT is sometimes
    -- a spelled-out word ('two'/'three'/'four' confirmed) instead of a digit.
    INSERT INTO STG_SALES (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, SOURCE_PRODUCT_ID, SALE_DATE, QUANTITY_UNITS)
    SELECT 'BRANCH_2', TO_CHAR(CNUMBER), TO_CHAR(PNUMBER), "DATE", PARSE_QUANTITY(AMOUNT)
    FROM DWT_BRANCH_2.BUYS;

    -- Branch 4: header (ORDER) + line items (ITEM) need to be joined.
    INSERT INTO STG_SALES (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, SOURCE_PRODUCT_ID, SALE_DATE, QUANTITY_UNITS)
    SELECT 'BRANCH_4', TO_CHAR(o.CID), TO_CHAR(i.PID), o."DATE", i.AMOUNT
    FROM DWT_BRANCH_4."ORDER" o
    JOIN DWT_BRANCH_4.ITEM i ON i.OID = o.ORDERID;

    COMMIT;
END LOAD_STG_SALES;
