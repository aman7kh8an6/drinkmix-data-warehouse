SELECT table_name, owner
FROM all_tables
WHERE owner LIKE 'DWT_BRANCH%';

SELECT table_name 
FROM all_tables 
WHERE owner = 'DWT_BRANCH_1';

--PRODUCTS TABLES BRANCH 1
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_1' 
AND table_name = 'PRODUCTS' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_1'
AND a.table_name = 'PRODUCTS'; 

--CUSTOMER TABLES BRANCH 1
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_1' 
AND table_name = 'CUSTOMER' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_1'
AND a.table_name = 'CUSTOMER'; 

--ORDER TABLES BRANCH 1
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_1' 
AND table_name = 'ORDER' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_1'
AND a.table_name = 'ORDER'; 

SELECT table_name 
FROM all_tables 
WHERE owner = 'DWT_BRANCH_2';

--BUYS TABLES BRANCH 2
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_2' 
AND table_name = 'BUYS' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_2'
AND a.table_name = 'BUYS'; 

--PRODUCT TABLES BRANCH 2
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_2' 
AND table_name = 'PRODUCT' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_2'
AND a.table_name = 'PRODUCT';

--CUSTOMER TABLES BRANCH 2
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_2' 
AND table_name = 'CUSTOMER' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_2'
AND a.table_name = 'CUSTOMER';


--PLACE TABLES BRANCH 2
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_2' 
AND table_name = 'PLACE' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_2'
AND a.table_name = 'PLACE';

SELECT table_name 
FROM all_tables 
WHERE owner = 'DWT_BRANCH_4';

--CUSTOMER TABLES BRANCH 4
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_4' 
AND table_name = 'CUSTOMER' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_4'
AND a.table_name = 'CUSTOMER';

--ORDER TABLES BRANCH 4
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_4' 
AND table_name = 'ORDER' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_4'
AND a.table_name = 'ORDER';


--PRODUCT TABLES BRANCH 4
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_4' 
AND table_name = 'PRODUCT' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_4'
AND a.table_name = 'PRODUCT';

--ITEM TABLES BRANCH 4
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_4' 
AND table_name = 'ITEM' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_4'
AND a.table_name = 'ITEM';

--SORT TABLES BRANCH 4
SELECT column_name, data_type, data_length, nullable
FROM all_tab_columns
WHERE owner = 'DWT_BRANCH_4' 
AND table_name = 'SORT' 
ORDER BY column_id;

SELECT a.constraint_name, a.constraint_type, b.column_name
FROM all_constraints a
JOIN all_cons_columns b ON a.constraint_name = b.constraint_name
WHERE a.owner = 'DWT_BRANCH_4'
AND a.table_name = 'SORT';


