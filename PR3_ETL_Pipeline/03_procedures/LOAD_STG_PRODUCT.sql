-- =====================================================================================
-- LOAD_STG_PRODUCT.sql
-- Step 3: read products from all three branches, normalize/clean them into
-- STG_PRODUCT, and compute the MATCH_KEY.
--
-- All three branches sell the same 29 products, and - unlike customer IDs - the
-- branch-local product ID is the SAME number in every branch for a given product
-- (confirmed: grouping STG_PRODUCT by SOURCE_PRODUCT_ID gives exactly 29 groups,
-- each containing all 3 branches). So products are matched on SOURCE_PRODUCT_ID,
-- PRODUCT_NAME is not reliable for matching because it sometimes
-- differs by branch even for the same product (e.g. ID 6 is "Apple-Peach" in
-- Branch 1's English label but "Apfel-Pfirsich" in Branch 2/4's German label;
-- ID 9 is "Forest Fuirt" vs "Waldfrucht"). Matching on name alone previously
-- produced 35 DIM_PRODUCT rows instead of 29 because of exactly this mismatch.
--
-- DEPENDS ON: 01_tables_and_alters.sql, CLEAN_NUMBER.sql (for text-typed
-- PRICE/SIZE cleanup).
-- =====================================================================================

CREATE OR REPLACE PROCEDURE LOAD_STG_PRODUCT AS
BEGIN
    DELETE FROM STG_PRODUCT;

    -- Branch 1: SORT is the raw category text; SZ is already numeric.
    INSERT INTO STG_PRODUCT (SOURCE_BRANCH, SOURCE_PRODUCT_ID, PRODUCT_NAME, UNIT_PRICE,
                              PRODUCT_TYPE, BOTTLE_SIZE_LITERS, PRODUCT_CATEGORY)
    SELECT 'BRANCH_1', TO_CHAR(ID), INITCAP(TRIM(NAME)), PRICE,
           UPPER(TRIM(SORT)), SZ, UPPER(TRIM(SORT))
    FROM DWT_BRANCH_1.PRODUCTS;

    -- Branch 2: PRICE is text and occasionally malformed (e.g. NUM=12 stores the
    -- price as '.0.71' - two periods). CLEAN_NUMBER handles that instead of a
    -- plain REPLACE(',', '.') which crashes on it with ORA-01722.
    INSERT INTO STG_PRODUCT (SOURCE_BRANCH, SOURCE_PRODUCT_ID, PRODUCT_NAME, UNIT_PRICE,
                              PRODUCT_TYPE, BOTTLE_SIZE_LITERS, PRODUCT_CATEGORY)
    SELECT 'BRANCH_2', TO_CHAR(NUM), INITCAP(TRIM(LABEL)),
           CLEAN_NUMBER(PRICE),
           UPPER(TRIM(TYPE)), LITER, UPPER(TRIM(TYPE))
    FROM DWT_BRANCH_2.PRODUCT;

    -- Branch 4: "SIZE" is text and can have the same kind of formatting issues;
    -- category comes from the separate SORT lookup table via SID.
    INSERT INTO STG_PRODUCT (SOURCE_BRANCH, SOURCE_PRODUCT_ID, PRODUCT_NAME, UNIT_PRICE,
                              PRODUCT_TYPE, BOTTLE_SIZE_LITERS, PRODUCT_CATEGORY)
    SELECT 'BRANCH_4', TO_CHAR(p.PRODUCTNUMBER), INITCAP(TRIM(p.NAME)), p.PRICE,
           UPPER(TRIM(s.NAME)),
           CLEAN_NUMBER(p."SIZE"),
           UPPER(TRIM(s.NAME))
    FROM DWT_BRANCH_4.PRODUCT p
    JOIN DWT_BRANCH_4.SORT s ON s.SORTNUMBER = p.SID;

    -- Match on the shared branch-local ID, not the name (see header note above).
    UPDATE STG_PRODUCT
    SET MATCH_KEY = SOURCE_PRODUCT_ID;

    COMMIT;
END LOAD_STG_PRODUCT;
/
