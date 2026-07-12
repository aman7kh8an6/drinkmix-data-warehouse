-- =====================================================================================
-- PARSE_QUANTITY.sql
-- Branch 2's BUYS.AMOUNT (VARCHAR2(5)) sometimes spells the quantity out as an
-- English word instead of a digit - confirmed in the actual data: 'two', 'three',
-- 'four'. The column's 5-character limit means only 'one'..'ten' could ever fit,
-- so the rest are included defensively even though only three of them were found.
-- Falls back to CLEAN_NUMBER for anything that's already a plain numeric string.
--
-- DEPENDS ON: CLEAN_NUMBER.sql (must be run first).
-- =====================================================================================

CREATE OR REPLACE FUNCTION PARSE_QUANTITY(p_raw IN VARCHAR2) RETURN NUMBER IS
BEGIN
    RETURN CASE UPPER(TRIM(p_raw))
                WHEN 'ONE'   THEN 1
                WHEN 'TWO'   THEN 2
                WHEN 'THREE' THEN 3
                WHEN 'FOUR'  THEN 4
                WHEN 'FIVE'  THEN 5
                WHEN 'SIX'   THEN 6
                WHEN 'SEVEN' THEN 7
                WHEN 'EIGHT' THEN 8
                WHEN 'NINE'  THEN 9
                WHEN 'TEN'   THEN 10
                ELSE CLEAN_NUMBER(p_raw)
           END;
END PARSE_QUANTITY;
/

-- Quick self-test: expect 2, 3, 4, 5 (numeric passthrough via CLEAN_NUMBER)
SELECT PARSE_QUANTITY('two') AS w1, PARSE_QUANTITY('three') AS w2,
       PARSE_QUANTITY('four') AS w3, PARSE_QUANTITY('5') AS n1
FROM DUAL;
