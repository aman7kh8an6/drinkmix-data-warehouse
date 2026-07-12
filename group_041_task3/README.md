# PR03 ETL - DrinkMix Data Warehouse

Loads `DWT_BRANCH_1` / `DWT_BRANCH_2` / `DWT_BRANCH_4` into the PR2 star schema
(`DIM_CUSTOMER`, `DIM_PRODUCT`, `DIM_BRANCH`, `DIM_TIME`, `FACT_SALES`).

Split into separate files by type (schema, functions, procedures, view,
verification) instead of one big script, so each piece can be reviewed and run
on its own. See `PR03_Report.pdf` for the full write-up of the approach,
decisions, and challenges we ran into.

## Folder structure

```
group_041_task3/
├── 01_schema/
│   └── 01_tables_and_alters.sql       staging tables, mapping tables, MATCH_KEY columns
├── 02_functions/
│   ├── CLEAN_NUMBER.sql               fixes malformed numeric text (e.g. '.0.71')
│   └── PARSE_QUANTITY.sql             handles spelled-out quantities ('two','three','four')
├── 03_procedures/
│   ├── LOAD_STG_CUSTOMER.sql          step 1: read/clean customers
│   ├── LOAD_DIM_CUSTOMER.sql   step 2 + 6: dedup customers, age group
│   ├── LOAD_STG_PRODUCT.sql           step 3: read/clean products
│   ├── LOAD_DIM_PRODUCT.sql    step 3: dedup products, per-branch pricing
│   ├── LOAD_DIM_BRANCH.sql            seeds the 3 branches
│   ├── LOAD_DIM_TIME.sql              builds the calendar dimension
│   ├── LOAD_STG_SALES.sql             reads raw order lines from all 3 branches
│   ├── LOAD_FACT_SALES.sql            step 5: aggregates into FACT_SALES (liters)
│   └── RUN_FULL_ETL.sql               runs everything above in order
├── 04_views/
│   └── V_FACT_SALES_TURNOVER.sql      step 4: turnover, computed on read
└── 05_verification/
    └── 01_verification_queries.sql    run last, checks the load worked
```

## How to create everything (run order matters)

Open each file in SQL Developer and run it as a script (F5), in this order.
Files within the same folder can be run in the order listed; folders must be
done in the order below because later files reference earlier ones.


1. **`01_schema/01_tables_and_alters.sql`** - creates the staging tables
   (`STG_CUSTOMER`, `STG_PRODUCT`, `STG_SALES`), the mapping tables
   (`CUSTOMER_BRANCH_MAP`, `PRODUCT_BRANCH_MAP`), and adds the `MATCH_KEY`
   columns to `DIM_CUSTOMER`/`DIM_PRODUCT`. Everything else depends on this.

2. **`02_functions/CLEAN_NUMBER.sql`**, then **`02_functions/PARSE_QUANTITY.sql`**
   - in that order, since `PARSE_QUANTITY` calls `CLEAN_NUMBER`. Each file's
   self-test `SELECT` runs automatically at the end - check the output matches
   the comment above it before moving on.

3. **`03_procedures/*.sql`** - create all nine procedures. Order doesn't
   matter for compiling them (Oracle allows forward references between stored
   procedures), except `RUN_FULL_ETL.sql` should be last since it calls all
   the others by name.

4. **`04_views/V_FACT_SALES_TURNOVER.sql`** - creates the turnover view.

5. Run the ETL itself:

   ```sql
   BEGIN
       RUN_FULL_ETL;
   END;
   /
   ```

7. **`05_verification/01_verification_queries.sql`** - check the row counts
   and totals look right (29 products, `FACT_SALES` populated, no NULL
   quantities, etc.).

## Re-running later

`RUN_FULL_ETL` is safe to call again any time new branch data shows up -
staging tables get rebuilt from scratch each run, while dimension and mapping
tables only add genuinely new rows (nothing gets duplicated).
