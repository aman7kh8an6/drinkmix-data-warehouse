-- =====================================================================================
-- LOAD_DIM_TIME.sql
-- Builds the calendar dimension: one row per day, spanning the full range of order
-- dates found across all three branches. Day/week/month/quarter/year are all
-- flattened onto each row (denormalized, matching the star schema design).
--
-- DEPENDS ON: DIM_TIME must already exist (created in PR02).
-- =====================================================================================

CREATE OR REPLACE PROCEDURE LOAD_DIM_TIME AS
    v_min_date DATE;
    v_max_date DATE;
BEGIN
    SELECT MIN(d), MAX(d) INTO v_min_date, v_max_date
    FROM (
        SELECT "DATE" AS d FROM DWT_BRANCH_1."ORDER"
        UNION ALL
        SELECT "DATE" FROM DWT_BRANCH_2.BUYS
        UNION ALL
        SELECT "DATE" FROM DWT_BRANCH_4."ORDER"
    );

    MERGE INTO DIM_TIME t
    USING (
        SELECT TO_NUMBER(TO_CHAR(v_min_date + LEVEL - 1, 'YYYYMMDD')) AS TIME_KEY,
               v_min_date + LEVEL - 1 AS CALENDAR_DATE
        FROM DUAL
        CONNECT BY LEVEL <= (v_max_date - v_min_date + 1)
    ) src
    ON (t.TIME_KEY = src.TIME_KEY)
    WHEN NOT MATCHED THEN
        INSERT (TIME_KEY, CALENDAR_DATE, DAY_OF_WEEK, CALENDAR_WEEK, CALENDAR_MONTH,
                CALENDAR_QUARTER, CALENDAR_YEAR)
        VALUES (src.TIME_KEY, src.CALENDAR_DATE,
                TRIM(TO_CHAR(src.CALENDAR_DATE, 'DAY')),
                TO_NUMBER(TO_CHAR(src.CALENDAR_DATE, 'IW')),
                TO_NUMBER(TO_CHAR(src.CALENDAR_DATE, 'MM')),
                TO_NUMBER(TO_CHAR(src.CALENDAR_DATE, 'Q')),
                TO_NUMBER(TO_CHAR(src.CALENDAR_DATE, 'YYYY')));

    COMMIT;
END LOAD_DIM_TIME;
