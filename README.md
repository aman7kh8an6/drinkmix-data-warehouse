# DrinkMix Data Warehouse

Course project for Data Warehouse Technologies (BTU Cottbus-Senftenberg) - a star-schema data warehouse for a fictional beverage retail chain, built up over three practical tasks.

## Project scope

1. **`TASK1/`** - analysed three independent branch databases (`DWT_BRANCH_1`, `DWT_BRANCH_2`, `DWT_BRANCH_4`), each with its own schema, naming conventions, and data types, and documented the design problems found in each (see `ER_Diagram_&Problems.pdf`).
2. **`group_41_task2/`** - designed a conformed star schema (`DIM_CUSTOMER`, `DIM_PRODUCT`, `DIM_BRANCH`, `DIM_TIME`, `FACT_SALES`) to unify the three branches (`DDL_SQL_Script.sql`, `MER&StarSchemaDiagram.pdf`).
3. **`group_041_task3/`** - built the ETL pipeline in Oracle PL/SQL that loads the three branch databases into the PR2 star schema: reads and cleans customers and products, deduplicates them across branches, calculates turnover and liters, and assigns customer age groups. Split into files by type (schema, functions, procedures, view, verification) - see `group_041_task3/README.md` for the exact run order, and `group_041_task3/PR03_Report.pdf` for the full write-up of decisions and challenges.

## A few real bugs solved along the way (PR3)

- Branch-local customer/product IDs aren't comparable across systems - customers are matched on name + address, products on a shared branch-local ID.
- Malformed source data (a price stored as `'.0.71'`, quantities spelled out as words like `'three'`) needed small defensive parsing functions before anything else could work.
- Product names differ by branch (English vs. German labels for the same product) - matching on name alone silently produced 35 products instead of 29.
- The same product is priced differently by different branches - price is tracked per branch+product, not as a single value per product.

Full write-up in `group_041_task3/PR03_Report.pdf`; inline comments throughout `group_041_task3/` explain the reasoning behind each decision.
