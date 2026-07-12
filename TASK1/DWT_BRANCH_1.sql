-- DDL for DWT_BRANCH_1

DESC DWT_BRANCH_1.CUSTOMER;

CREATE TABLE DWT_BRANCH_1.CUSTOMER (
    ID NUMBER(11,0),
    NAME VARCHAR2(40),
    SURNAME VARCHAR2(40) NOT NULL,
    STR VARCHAR2(60),
    NO VARCHAR2(5),
    ZIP VARCHAR2(5) NOT NULL, -- zip can be a number instead of a varchar2, and if we are using zip than we may not need to use place.
    PLACE VARCHAR2(50) NOT NULL,
    GEND CHAR(1),
    BDAY DATE,
    PRIMARY KEY (ID)
);


DESC DWT_BRANCH_1.PRODUCTS;

CREATE TABLE DWT_BRANCH_1.PRODUCTS (
    ID NUMBER(11,0),
    NAME VARCHAR2(50) NOT NULL,
    SORT VARCHAR2(20),
    SZ NUMBER(3,2) NOT NULL,
    PRICE NUMBER(3,2) NOT NULL,
    PRIMARY KEY (ID)
);

DESC DWT_BRANCH_1."ORDER"";

CREATE TABLE DWT_BRANCH_1.ORDER (
    "ORDER" VARCHAR2(15), 
    "DATE" DATE NOT NULL, -- use of reserve word as a column (order, date)
    AMOUNT CHAR(5) NOT NULL,
    CSTMR NUMBER(11,0),
    PRO NUMBER(11,0),
    UNIQUE ("DATE", CSTMR, PRO), -- unique key but no primary key in order table.
    FOREIGN KEY (CSTMR) REFERENCES CUSTOMER(ID),
    FOREIGN KEY (PRO) REFERENCES PRODUCTS(ID)
);


-- SELECT STATEMENT 

-- dwt_branch_1.customer

SELECT
    id,
    name,
    surname,
    str,
    no,
    zip,
    place,
    gend,
    bday
FROM
    dwt_branch_1.customer;
    
SELECT
    COUNT(*)
FROM
    dwt_branch_1.customer;--47251

SELECT * FROM dwt_branch_1.customer
FETCH FIRST 10 ROWS ONLY;


-- dwt_branch_1."ORDER" (NAME ORDER IS AMBIGUOUS AS IT IS A RESERVED WORD)

SELECT
    "ORDER",
    "DATE",
    amount,
    cstmr,
    pro
FROM
    dwt_branch_1."ORDER";
    
SELECT
    COUNT(*)
FROM
    dwt_branch_1."ORDER";--70776

SELECT * FROM dwt_branch_1.customer
FETCH FIRST 10 ROWS ONLY;


-- dwt_branch_1.products

SELECT
    id,
    name,
    sort,
    sz,
    price
FROM
    dwt_branch_1.products;

SELECT COUNT(*) FROM dwt_branch_1.products;--29

-- CUSTOMER and ORDER

SELECT COUNT(*) FROM dwt_branch_1.customer a JOIN dwt_branch_1."ORDER" b ON a.ID = b.cstmr; -- 70776

SELECT COUNT(*) FROM dwt_branch_1.customer a LEFT JOIN dwt_branch_1."ORDER" b ON a.ID = b.cstmr; --94401 (NOT ALL CUSTOMER IN THE ORDER TABLE)

-- PRODUCT and ORDER
SELECT PRO, COUNT(*) FROM dwt_branch_1."ORDER" GROUP BY PRO ORDER BY PRO;-- 1-28 PRO IDS ONLY.

SELECT COUNT(*) FROM dwt_branch_1.products a LEFT JOIN dwt_branch_1."ORDER" b ON a.pro = b.cstmr; -- 70776 
--(GIVING EVERY RECORD OF ORDER AS ALL 1-28 KEYS PRESENT IN THE ORDER)







