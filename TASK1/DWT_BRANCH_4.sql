-- DDL FOR DWT_BRANCH_4

DESC DWT_BRANCH_4.CUSTOMER;

-- 1. CUSTOMER Table
CREATE TABLE DWT_BRANCH_4.CUSTOMER (
    CUSTUMERNUMBER NUMBER(10,0), 
    NAME VARCHAR2(30) NOT NULL,
    FIRSTNAME VARCHAR2(30) NOT NULL, -- the first name is not null, in other branches last name is not null, there is a inconsistency.
    STREET_NO VARCHAR2(40), -- street_no and the data type varchar2 creating a confusion, whether it is asking to insert a number or string.
    ZIP NUMBER(5,0),
    PLACE VARCHAR2(30),
    GENDER CHAR(1),
    BDAY DATE,
    PRIMARY KEY (CUSTUMERNUMBER)
);


DESC DWT_BRANCH_4.PRODUCT;

-- 2. PRODUCT Table
CREATE TABLE DWT_BRANCH_4.PRODUCT (
    PRODUCTNUMBER NUMBER(12,0),
    NAME VARCHAR2(30) NOT NULL,
    SID NUMBER(5,0) NOT NULL,
    "SIZE" VARCHAR2(20), -- use of the reserved keyword as a column (size).
    PRICE NUMBER(3,2) NOT NULL,
    PRIMARY KEY (PRODUCTNUMBER) 
);

DESC DWT_BRANCH_4.SORT;

-- 3. SORT Table (Reference for PRODUCT)
CREATE TABLE DWT_BRANCH_4.SORT (
    SORTNUMBER NUMBER(3,0),
    NAME VARCHAR2(30) NOT NULL,
    PRIMARY KEY (SORTNUMBER)
);

DESC DWT_BRANCH_4."ORDER";

-- 4. ORDER Table 
CREATE TABLE DWT_BRANCH_4."ORDER" (
    ORDERID NUMBER(13,0),
    CID NUMBER(10,0) NOT NULL,
    "DATE" DATE NOT NULL, -- use of reserved keyword 'date' as a column.
    PRIMARY KEY (ORDERID)
);

DESC DWT_BRANCH_4.ITEM;

-- 5. ITEM Table 
CREATE TABLE DWT_BRANCH_4.ITEM (
    OID NUMBER(13,0),
    PID NUMBER(5,0),
    AMOUNT NUMBER(12,0),
    PRIMARY KEY (OID, PID, AMOUNT) -- amount can not be included as a pk, it will create a severe problem.
);


-- SELECT Statement

-- dwt_branch_4.customer 

SELECT
    custumernumber,
    name,
    firstname,
    street_no,
    zip,
    place,
    gender,
    bday
FROM
    dwt_branch_4.customer;
    

SELECT
    count(*)
FROM
    dwt_branch_4.customer; --47251


select * from  dwt_branch_4.customer FETCH FIRST 10 ROWS ONLY;


--dwt_branch_4.item

SELECT
    oid,
    amount,
    pid
FROM
    dwt_branch_4.item;
    
SELECT COUNT(*) FROM dwt_branch_4.item; -- 71020

SELECT
    oid,
    amount,
    pid
FROM
    dwt_branch_4.item FETCH FIRST 10 ROWS ONLY;
    
SELECT OID, PID, AMOUNT, COUNT(*) FROM dwt_branch_4.item GROUP BY (OID, PID, AMOUNT) HAVING COUNT(*) > 1; -- 0 (COMPOSITE KEYS)

--dwt_branch_4."ORDER"

SELECT
    orderid,
    cid,
    "DATE"
FROM
    dwt_branch_4."ORDER";

SELECT
    COUNT(*)
FROM
    dwt_branch_4."ORDER";--23626
    
SELECT
    orderid,
    cid,
    "DATE"
FROM
    dwt_branch_4."ORDER" FETCH FIRST 10 ROWS ONLY;


--dwt_branch_4.product

SELECT
    productnumber,
    name,
    sid,
    "SIZE",
    price
FROM
    dwt_branch_4.product;
    
SELECT
    COUNT(*)
FROM
    dwt_branch_4.product; --29


-- dwt_branch_4.sort

SELECT
    sortnumber,
    name
FROM
    dwt_branch_4.sort;
    
SELECT
    COUNT(*)
FROM
    dwt_branch_4.sort; --2


    
-- CUSTOMER and ORDER

SELECT COUNT(*) FROM dwt_branch_4.customer a JOIN dwt_branch_4."ORDER" b ON a.CUSTUMERNUMBER = b.CID; -- 23626

SELECT COUNT(*) FROM dwt_branch_4.customer a RIGHT JOIN dwt_branch_4."ORDER" b ON a.CUSTUMERNUMBER = b.CID; -- 23626


-- ITEM and ORDER

SELECT COUNT(*) FROM dwt_branch_4.ITEM a JOIN dwt_branch_4."ORDER" b ON a.OID = b.ORDERID; -- 71020

-- ITEM and PRODUCT
SELECT COUNT(*) FROM dwt_branch_4.ITEM a JOIN dwt_branch_4.PRODUCT b ON a.PID = b.PRODUCTNUMBER; -- 71021



















