-- =====================================================================================
-- RUN_FULL_ETL.sql
-- Orchestration: calls every load procedure in the correct dependency order, so a
-- full reload is a single call.
--
-- DEPENDS ON: every other file in 02_functions/ and 03_procedures/ having already
-- been created.
-- =====================================================================================

CREATE OR REPLACE PROCEDURE RUN_FULL_ETL AS
BEGIN
    LOAD_DIM_BRANCH;
    LOAD_DIM_TIME;
    LOAD_STG_CUSTOMER;
    MATCH_AND_LOAD_CUSTOMERS;
    LOAD_STG_PRODUCT;
    MATCH_AND_LOAD_PRODUCTS;
    LOAD_STG_SALES;
    LOAD_FACT_SALES;
    DBMS_OUTPUT.PUT_LINE('ETL completed at ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END RUN_FULL_ETL;
/

-- Run it:
-- BEGIN RUN_FULL_ETL; END;
-- /
