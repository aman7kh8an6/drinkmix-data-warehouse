-- =====================================================================================
-- CLEAN_NUMBER.sql
-- Utility function: some branch text-typed numeric fields (Branch 2 PRICE, Branch 4
-- SIZE) contain messy formatting - stray extra separators, German-style thousands
-- grouping (1.234,56), plain commas as decimals, etc. Example found in
-- DWT_BRANCH_2.PRODUCT: NUM=12 has PRICE = '.0.71' (two periods), which a plain
-- REPLACE(',', '.') cannot fix and which crashes TO_NUMBER with ORA-01722.
--
-- Treats the LAST comma/period in the string as the real decimal point (the normal
-- convention regardless of , or . being used) and strips every other separator
-- before it as noise/thousands-grouping, then converts to NUMBER.
--
-- No dependencies. Run before PARSE_QUANTITY.sql (which calls this as a fallback).
-- =====================================================================================

CREATE OR REPLACE FUNCTION CLEAN_NUMBER(p_raw IN VARCHAR2) RETURN NUMBER IS
    v_str      VARCHAR2(50);
    v_sep_cnt  PLS_INTEGER;
    v_last_pos PLS_INTEGER;
    v_result   VARCHAR2(50);
BEGIN
    IF p_raw IS NULL THEN
        RETURN NULL;
    END IF;

    -- keep only digits and separators; drop currency symbols, spaces, letters, etc.
    v_str := REGEXP_REPLACE(TRIM(p_raw), '[^0-9,\.]', '');

    IF v_str IS NULL THEN
        RETURN NULL;
    END IF;

    -- Check the separator count BEFORE calling REGEXP_INSTR: its occurrence
    -- argument must be a positive integer, so when there's no separator at all
    -- (count = 0, e.g. plain '0' or '150') we must skip REGEXP_INSTR entirely -
    -- passing occurrence=0 into it raises ORA-01428, it does not just return 0.
    v_sep_cnt := REGEXP_COUNT(v_str, '[,\.]');

    IF v_sep_cnt = 0 THEN
        v_result := v_str; -- plain integer, no separator at all
    ELSE
        v_last_pos := REGEXP_INSTR(v_str, '[,\.]', 1, v_sep_cnt); -- position of the LAST separator
        v_result := REGEXP_REPLACE(SUBSTR(v_str, 1, v_last_pos - 1), '[,\.]', '')
                    || '.' || SUBSTR(v_str, v_last_pos + 1);
    END IF;

    RETURN TO_NUMBER(v_result);
END CLEAN_NUMBER;
/

-- Quick self-test (run once to sanity check): expect 0, 150, 0.5, 0.71, 3.1, 3, 1234.56
SELECT CLEAN_NUMBER('0') AS t0, CLEAN_NUMBER('150') AS t0b,
       CLEAN_NUMBER('.5') AS t1, CLEAN_NUMBER('.0.71') AS t2, CLEAN_NUMBER('3,10') AS t3,
       CLEAN_NUMBER('3.00') AS t4, CLEAN_NUMBER('1.234,56') AS t5
FROM DUAL;
