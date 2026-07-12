-- DDL for DWT_BRANCH_2

DESC DWT_BRANCH_1.PRODUCT

CREATE TABLE DWT_BRANCH_2.PRODUCT (
    NUM NUMBER(12,0) NOT NULL, -- instead of 'num' , there could be more meaningful column name we can give for product id.
    LABEL VARCHAR2(40) NOT NULL,
    TYPE VARCHAR2(30) NOT NULL,
    LITER NUMBER(3,2) NOT NULL,
    PRICE VARCHAR2(10) NOT NULL, -- price should be a number not varchar2.
    PRIMARY KEY (NUM)
);

DESC DWT_BRANCH_1.CUSTOMER

CREATE TABLE DWT_BRANCH_2.CUSTOMER (
    NUM NUMBER(12,0) NOT NULL, -- instead of 'num', there could be more meaningful column name we can give for customer id.
    LASTNAME VARCHAR2(50) NOT NULL, 
    FIRSTNAME VARCHAR2(50),
    PLACEID NUMBER(5,0),
    BDAY DATE,
	PRIMARY KEY (NUM),
    UNIQUE (LASTNAME, FIRSTNAME) -- if we make the firstname, lastname unique then there could be a problem when the same name, surname customer we need to insert in the table. 
);

DESC DWT_BRANCH_1.PLACE

CREATE TABLE DWT_BRANCH_2.PLACE (
    PLID NUMBER(5,0) NOT NULL,
    STR_NO VARCHAR2(70), -- str_no is varchar2, and the data is also a string, we can give it a better name instead of suffix it with no.
    ZIP_PLACE VARCHAR2(100) NOT NULL,
    PRIMARY KEY (PLID)
);

DESC DWT_BRANCH_1.BUYS

CREATE TABLE DWT_BRANCH_2.BUYS (
    CNUMBER NUMBER(22) NOT NULL,
    PNUMBER NUMBER(22) NOT NULL,
    AMOUNT VARCHAR2(5) NOT NULL, -- the amount column in the buys table is defined as varchar2(5) (text) instead of a number type
    "DATE" DATE NOT NULL, -- use of reserved keyword 'date' as column name.
    PRIMARY KEY (CNUMBER, PNUMBER, AMOUNT, "DATE") -- including amount in a primary key is a severe design flaw
);


-- SELECT STATEMENTS

--DWT_BRANCH_2.BUYS 
SELECT
    cnumber,
    pnumber,
    amount,
    "DATE"
FROM
    dwt_branch_2.buys;

SELECT
    COUNT(*)
FROM
    dwt_branch_2.buys; --71000
    
SELECT
    cnumber,
    pnumber,
    amount,
    "DATE"
FROM
    dwt_branch_2.buys FETCH FIRST 10 ROWS ONLY;

-- dwt_branch_2.customer
SELECT
    num,
    lastname,
    firstname,
    placeid,
    bday
FROM
    dwt_branch_2.customer;
    
SELECT
    COUNT(*)
FROM
    dwt_branch_2.customer;-- 47251
    
SELECT
    num,
    lastname,
    firstname,
    placeid,
    bday
FROM
    dwt_branch_2.customer FETCH FIRST 10 ROWS ONLY;

-- dwt_branch_2.place
SELECT
    plid,
    str_no,
    zip_place
FROM
    dwt_branch_2.place;
    
SELECT
    COUNT(*)
FROM
    dwt_branch_2.place;-- 38408
    
SELECT
    plid,
    str_no,
    zip_place
FROM
    dwt_branch_2.place FETCH FIRST 10 ROWS ONLY;
    
    
-- dwt_branch_2.product

SELECT
    num,
    label,
    type,
    liter,
    price
FROM
    dwt_branch_2.product;

SELECT
    COUNT(*)
FROM
    dwt_branch_2.product;-- 29


SELECT
    num,
    label,
    type,
    liter,
    price
FROM
    dwt_branch_2.product FETCH FIRST 10 ROWS ONLY;
    
-- BUYS AND CUSTOMER
SELECT COUNT(*) FROM DWT_BRANCH_2.BUYS A JOIN DWT_BRANCH_2.CUSTOMER B ON A.CNUMBER = B.NUM;--71000

SELECT COUNT(*) FROM DWT_BRANCH_2.BUYS A RIGHT JOIN DWT_BRANCH_2.CUSTOMER B ON A.CNUMBER = B.NUM;--94625

-- BUYS AND PRODUCT
SELECT COUNT(*) FROM DWT_BRANCH_2.BUYS A JOIN DWT_BRANCH_2.PRODUCT B ON A.CNUMBER = B.NUM;--45

SELECT COUNT(*) FROM DWT_BRANCH_2.BUYS A RIGHT JOIN DWT_BRANCH_2.PRODUCT B ON A.CNUMBER = B.NUM;--59

