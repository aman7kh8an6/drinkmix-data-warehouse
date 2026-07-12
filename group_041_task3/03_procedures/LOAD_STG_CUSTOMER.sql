-- =====================================================================================
-- LOAD_STG_CUSTOMER.sql
-- Step 1: read customers from all three branches, normalize and clean them into
-- STG_CUSTOMER, and compute the duplicate-detection MATCH_KEY (name + full address).
--
-- DEPENDS ON: 01_tables_and_alters.sql (STG_CUSTOMER table must exist).
-- =====================================================================================

CREATE OR REPLACE PROCEDURE LOAD_STG_CUSTOMER AS
BEGIN
    DELETE FROM STG_CUSTOMER;

    -- Branch 1: STREET / HOUSE_NUMBER already separate columns; GEND is 'M'/'W'.
    INSERT INTO STG_CUSTOMER (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, FIRST_NAME, LAST_NAME,
                               STREET, HOUSE_NUMBER, ZIP_CODE, CITY, GENDER, DATE_OF_BIRTH)
    SELECT 'BRANCH_1',
           TO_CHAR(ID),
           INITCAP(TRIM(NAME)),
           INITCAP(TRIM(SURNAME)),
           INITCAP(TRIM(STR)),
           TRIM(NO),
           LPAD(TRIM(ZIP), 5, '0'),
           INITCAP(TRIM(PLACE)),
           CASE UPPER(TRIM(GEND))
                WHEN 'M' THEN 'MALE'
                WHEN 'W' THEN 'FEMALE'
                WHEN 'F' THEN 'FEMALE'
                ELSE 'UNKNOWN'
           END,
           BDAY
    FROM DWT_BRANCH_1.CUSTOMER;

    -- Branch 2: STR_NO = "<street> <house number>", ZIP_PLACE = "<zip> <city>";
    -- source has NO gender column at all.
    INSERT INTO STG_CUSTOMER (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, FIRST_NAME, LAST_NAME,
                               STREET, HOUSE_NUMBER, ZIP_CODE, CITY, GENDER, DATE_OF_BIRTH)
    SELECT 'BRANCH_2',
           TO_CHAR(c.NUM),
           INITCAP(TRIM(c.FIRSTNAME)),
           INITCAP(TRIM(c.LASTNAME)),
           INITCAP(TRIM(REGEXP_REPLACE(p.STR_NO, '\s*[0-9]+[A-Za-z]?\s*$', ''))),
           TRIM(REGEXP_SUBSTR(p.STR_NO, '[0-9]+[A-Za-z]?\s*$')),
           LPAD(REGEXP_SUBSTR(p.ZIP_PLACE, '^[0-9]{1,5}'), 5, '0'),
           INITCAP(TRIM(REGEXP_REPLACE(p.ZIP_PLACE, '^[0-9]{1,5}\s*', ''))),
           'UNKNOWN',
           c.BDAY
    FROM DWT_BRANCH_2.CUSTOMER c
    JOIN DWT_BRANCH_2.PLACE p ON p.PLID = c.PLACEID;

    -- Branch 4: STREET_NO = "<street> <house number>"; ZIP/PLACE already separate.
    INSERT INTO STG_CUSTOMER (SOURCE_BRANCH, SOURCE_CUSTOMER_ID, FIRST_NAME, LAST_NAME,
                               STREET, HOUSE_NUMBER, ZIP_CODE, CITY, GENDER, DATE_OF_BIRTH)
    SELECT 'BRANCH_4',
           TO_CHAR(CUSTUMERNUMBER),
           INITCAP(TRIM(FIRSTNAME)),
           INITCAP(TRIM(NAME)),
           INITCAP(TRIM(REGEXP_REPLACE(STREET_NO, '\s*[0-9]+[A-Za-z]?\s*$', ''))),
           TRIM(REGEXP_SUBSTR(STREET_NO, '[0-9]+[A-Za-z]?\s*$')),
           LPAD(TRIM(TO_CHAR(ZIP)), 5, '0'),
           INITCAP(TRIM(PLACE)),
           CASE UPPER(TRIM(GENDER))
                WHEN 'M' THEN 'MALE'
                WHEN 'W' THEN 'FEMALE'
                WHEN 'F' THEN 'FEMALE'
                ELSE 'UNKNOWN'
           END,
           BDAY
    FROM DWT_BRANCH_4.CUSTOMER;

    -- Task rule: "the same customer always has the same address, no matter the
    -- branch or time" -> this combination IS the duplicate-detection key.
    UPDATE STG_CUSTOMER
    SET MATCH_KEY = UPPER(TRIM(FIRST_NAME)) || '|' || UPPER(TRIM(LAST_NAME)) || '|' ||
                    UPPER(TRIM(STREET))     || '|' || UPPER(TRIM(HOUSE_NUMBER)) || '|' ||
                    ZIP_CODE                || '|' || UPPER(TRIM(CITY));

    COMMIT;
END LOAD_STG_CUSTOMER;