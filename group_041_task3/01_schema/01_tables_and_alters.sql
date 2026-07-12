-- =====================================================================================
-- 01_tables_and_alters.sql
-- Additive schema changes + new tables needed by the ETL.
-- Please run this FIRST, before any function/procedure file.
-- DIM_CUSTOMER, DIM_PRODUCT, DIM_BRANCH, DIM_TIME, FACT_SALES already created in task 2 (in PR02's DDL_SQL_Script.sql).
-- =====================================================================================

-- Natural-key columns for idempotent dedup (does not touch existing PK/FK design)
ALTER TABLE DIM_CUSTOMER ADD (MATCH_KEY VARCHAR2(500));
ALTER TABLE DIM_CUSTOMER ADD CONSTRAINT UQ_DIM_CUSTOMER_MATCHKEY UNIQUE (MATCH_KEY);

ALTER TABLE DIM_PRODUCT ADD (MATCH_KEY VARCHAR2(300));
ALTER TABLE DIM_PRODUCT ADD CONSTRAINT UQ_DIM_PRODUCT_MATCHKEY UNIQUE (MATCH_KEY);

-- Persisted customer-to-branch mapping (explicitly required by the task sheet:
-- "Once found mappings of customers to branches should be saved separately.")
CREATE TABLE CUSTOMER_BRANCH_MAP (
    SOURCE_BRANCH       VARCHAR2(10) NOT NULL,
    SOURCE_CUSTOMER_ID  VARCHAR2(50) NOT NULL,
    CUSTOMER_KEY        NUMBER NOT NULL,
    LOAD_DATE           DATE DEFAULT SYSDATE,
    CONSTRAINT PK_CUST_BRANCH_MAP PRIMARY KEY (SOURCE_BRANCH, SOURCE_CUSTOMER_ID),
    CONSTRAINT FK_CUST_BRANCH_MAP FOREIGN KEY (CUSTOMER_KEY) REFERENCES DIM_CUSTOMER(CUSTOMER_KEY)
);

-- Same idea for products (not explicitly required, but needed to resolve fact rows
-- back to the right PRODUCT_KEY, and mirrors the required customer mapping).
-- UNIT_PRICE lives here too (not just on DIM_PRODUCT): the same product is sold at
-- slightly different prices per branch (e.g. 3.00 / 3.10 / 3.12), so price is a
-- branch+product fact, not a product-only fact. DIM_PRODUCT.UNIT_PRICE holds a
-- single reference price; this column holds what each branch actually charges,
-- which is what turnover must use.
CREATE TABLE PRODUCT_BRANCH_MAP (
    SOURCE_BRANCH       VARCHAR2(10) NOT NULL,
    SOURCE_PRODUCT_ID   VARCHAR2(50) NOT NULL,
    PRODUCT_KEY         NUMBER NOT NULL,
    UNIT_PRICE          NUMBER(10,2),
    LOAD_DATE           DATE DEFAULT SYSDATE,
    CONSTRAINT PK_PROD_BRANCH_MAP PRIMARY KEY (SOURCE_BRANCH, SOURCE_PRODUCT_ID),
    CONSTRAINT FK_PROD_BRANCH_MAP FOREIGN KEY (PRODUCT_KEY) REFERENCES DIM_PRODUCT(PRODUCT_KEY)
);

-- Staging tables ( read / normalize / clean, before dedup)
CREATE TABLE STG_CUSTOMER (
    SOURCE_BRANCH       VARCHAR2(10),
    SOURCE_CUSTOMER_ID  VARCHAR2(50),
    FIRST_NAME          VARCHAR2(100),
    LAST_NAME           VARCHAR2(100),
    STREET              VARCHAR2(150),
    HOUSE_NUMBER        VARCHAR2(20),
    ZIP_CODE            VARCHAR2(20),
    CITY                VARCHAR2(100),
    GENDER              VARCHAR2(20),
    DATE_OF_BIRTH       DATE,
    MATCH_KEY           VARCHAR2(500)
);

CREATE TABLE STG_PRODUCT (
    SOURCE_BRANCH       VARCHAR2(10),
    SOURCE_PRODUCT_ID   VARCHAR2(50),
    PRODUCT_NAME        VARCHAR2(150),
    UNIT_PRICE          NUMBER(10,2),
    PRODUCT_TYPE        VARCHAR2(100),
    BOTTLE_SIZE_LITERS  NUMBER(5,2),
    PRODUCT_CATEGORY    VARCHAR2(30),
    MATCH_KEY           VARCHAR2(300)
);

CREATE TABLE STG_SALES (
    SOURCE_BRANCH       VARCHAR2(10),
    SOURCE_CUSTOMER_ID  VARCHAR2(50),
    SOURCE_PRODUCT_ID   VARCHAR2(50),
    SALE_DATE           DATE,
    QUANTITY_UNITS      NUMBER(12,2)
);
