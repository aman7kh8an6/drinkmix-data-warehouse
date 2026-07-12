-- =====================================================================================
-- LOAD_DIM_CUSTOMER.sql
-- Step 2 (duplicate detection) + step 6 (age group): collapses STG_CUSTOMER rows
-- sharing a MATCH_KEY into one DIM_CUSTOMER row per real customer, then rebuilds
-- the full branch-local-id -> CUSTOMER_KEY mapping in CUSTOMER_BRANCH_MAP (the
-- mapping the task sheet requires to be saved separately).
--
-- DEPENDS ON: 01_tables_and_alters.sql, LOAD_STG_CUSTOMER.sql having populated
-- STG_CUSTOMER.
-- =====================================================================================

CREATE OR REPLACE PROCEDURE LOAD_DIM_CUSTOMER AS 
BEGIN
    INSERT INTO DIM_CUSTOMER (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, FIRST_NAME, LAST_NAME,
                               STREET, HOUSE_NUMBER, ZIP_CODE, CITY, GENDER, DATE_OF_BIRTH,
                               AGE_GROUP, MATCH_KEY)
    SELECT SOURCE_BRANCH, SOURCE_CUSTOMER_ID, FIRST_NAME, LAST_NAME, STREET, HOUSE_NUMBER,
           ZIP_CODE, CITY, GENDER, DATE_OF_BIRTH, AGE_GROUP, MATCH_KEY
    FROM (
        SELECT s.*,
               CASE
                   WHEN s.DATE_OF_BIRTH IS NULL THEN 'UNKNOWN'
                   WHEN MONTHS_BETWEEN(SYSDATE, s.DATE_OF_BIRTH) / 12 < 18 THEN '<18'
                   WHEN MONTHS_BETWEEN(SYSDATE, s.DATE_OF_BIRTH) / 12 < 26 THEN '18-25'
                   WHEN MONTHS_BETWEEN(SYSDATE, s.DATE_OF_BIRTH) / 12 < 36 THEN '26-35'
                   WHEN MONTHS_BETWEEN(SYSDATE, s.DATE_OF_BIRTH) / 12 < 46 THEN '36-45'
                   WHEN MONTHS_BETWEEN(SYSDATE, s.DATE_OF_BIRTH) / 12 < 56 THEN '46-55'
                   WHEN MONTHS_BETWEEN(SYSDATE, s.DATE_OF_BIRTH) / 12 < 66 THEN '56-65'
                   ELSE '66+'
               END AS AGE_GROUP,
               ROW_NUMBER() OVER (
                   PARTITION BY s.MATCH_KEY
                   ORDER BY CASE WHEN s.GENDER != 'UNKNOWN' THEN 0 ELSE 1 END, s.SOURCE_BRANCH
               ) AS RN
        FROM STG_CUSTOMER s
        WHERE NOT EXISTS (SELECT 1 FROM DIM_CUSTOMER d WHERE d.MATCH_KEY = s.MATCH_KEY)
    )
    WHERE RN = 1;

    -- Rebuild the full branch-local-id -> CUSTOMER_KEY mapping. This is the
    -- "mapping saved separately" the task requires, and is what makes re-running
    -- the load idempotent (no duplicate DIM_CUSTOMER rows on a second run).
    MERGE INTO CUSTOMER_BRANCH_MAP m
    USING (
        SELECT s.SOURCE_BRANCH, s.SOURCE_CUSTOMER_ID, d.CUSTOMER_KEY
        FROM STG_CUSTOMER s
        JOIN DIM_CUSTOMER d ON d.MATCH_KEY = s.MATCH_KEY
    ) src
    ON (m.SOURCE_BRANCH = src.SOURCE_BRANCH AND m.SOURCE_CUSTOMER_ID = src.SOURCE_CUSTOMER_ID)
    WHEN NOT MATCHED THEN
        INSERT (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, CUSTOMER_KEY)
        VALUES (src.SOURCE_BRANCH, src.SOURCE_CUSTOMER_ID, src.CUSTOMER_KEY);

    COMMIT;
END LOAD_DIM_CUSTOMER
