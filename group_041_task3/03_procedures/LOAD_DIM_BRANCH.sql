-- =====================================================================================
-- LOAD_DIM_BRANCH.sql
-- Seeds the three branches into DIM_BRANCH. No source table describes the branches
-- themselves, so GEOGRAPHICAL_REGION is seeded as 'EAST','WEST','SOUTH' placeholder -
-- replaced with real region names.
--
-- MUST be run (not just compiled!) before LOAD_FACT_SALES, which inner-joins
-- DIM_BRANCH to resolve BRANCH_KEY - if this table is empty, FACT_SALES silently
-- loads zero rows regardless of whether everything else is correct.
--
-- DEPENDS ON: DIM_BRANCH must already exist (created in PR02).
-- =====================================================================================

CREATE OR REPLACE PROCEDURE LOAD_DIM_BRANCH AS
BEGIN
    MERGE INTO DIM_BRANCH b
    USING (
        SELECT 'BRANCH_1' AS BRANCH_NAME, 'EAST' AS GEOGRAPHICAL_REGION FROM DUAL UNION ALL
        SELECT 'BRANCH_2', 'WEST' FROM DUAL UNION ALL
        SELECT 'BRANCH_4', 'SOUTH' FROM DUAL
    ) src
    ON (b.BRANCH_NAME = src.BRANCH_NAME)
    WHEN NOT MATCHED THEN
        INSERT (BRANCH_NAME, GEOGRAPHICAL_REGION) VALUES (src.BRANCH_NAME, src.GEOGRAPHICAL_REGION);

    COMMIT;
END LOAD_DIM_BRANCH;