-- sql/duckdb/asbourgeois_library_bootstrap.sql
-- ============================================================
-- PURPOSE
-- ============================================================
-- Creates retail tables and loads data from CSV files (DuckDB).
--
-- ASSUMPTION:
-- We always run all commands from the project root directory.
--
-- EXPECTED PROJECT PATHS (relative to repo root):
--   SQL:  sql/duckdb/asbourgeois_library_bootstrap.sql
--   CSV:  data/library/checkout.csv
--   CSV:  data/library/branch.csv
--   DB:   artifacts/duckdb/library.duckdb
--
--
-- ============================================================
-- TOPIC DOMAINS + 1:M RELATIONSHIPS
-- ============================================================
-- OUR DOMAINS:
-- Each domain (e.g. library) has two tables.
-- They are related in a 1-to-many relationship (1:M).
--
-- GENERAL:
-- In a 1-to-many relationship:
-- - The one table (1) is the independent/parent table.
--   It does not depend on any other table.
-- - The many table (M) is the dependent/child table.
--   It depends on the independent/parent table.
-- - They are related by a foreign key in the dependent/child table
--   that references the primary key in the independent/parent table.
--
-- OUR DOMAIN: LIBRARY
-- In libraries, items are check out using different systems.
-- Therefore, we have two tables: branch (1) and checkout (M).
-- - The branch table is the independent/parent table (1).
-- - The checkout table is the dependent/child table (M).
-- - The foreign key in the checkout table references the primary key in the branch table.
--
-- REQ: Tables must be created in order to satisfy foreign key constraints.
-- REQ: Data must be loaded in order to satisfy foreign key constraints.
--
--
-- ============================================================
-- EXECUTION: ATOMIC BOOTSTRAP (ALL OR NOTHING)
-- ============================================================
-- Use a transaction to ensure atomicity.
-- Atomicity: either all operations succeed,
-- or none do and the database remains unchanged.
-- Start with BEGIN TRANSACTION; and end with COMMIT; if all succeed.
-- If any operation fails, the database will ROLLBACK to undo all changes.
-- This ensures the database is never left in a partial or inconsistent state.
BEGIN TRANSACTION;
--
--
-- ============================================================
-- STEP 1: CREATE TABLES (PARENT FIRST, THEN CHILD)
-- ============================================================
-- The independent table must be created first.
-- In libraries, branches and systems used are independent of what items are checked out.
-- Therefore, create the branch table before the checkout table.
--
-- Create the `branch` table using DuckDB SQL syntax and data types.
-- In our table, all the fields are required (NOT NULL).
-- This means that every record must have a value for these fields.
-- The primary key is branch_id, which uniquely identifies each item.
CREATE TABLE IF NOT EXISTS branch (
  -- Every table must have a primary key that uniquely identifies each record.
  branch_id TEXT PRIMARY KEY,
  branch_name TEXT NOT NULL,
  city TEXT NOT NULL,
  system_name TEXT NOT NULL
);
-- Create the `checkout` table using DuckDB SQL syntax and data types.
CREATE TABLE IF NOT EXISTS checkout (
  -- Every table must have a primary key that uniquely identifies each record.
  checkout_id TEXT PRIMARY KEY,
  -- Foreign key that references the primary key in the store table. It cannot be NULL.
  branch_id TEXT NOT NULL,
  -- All remaining fields are also required (NOT NULL).
  material_type TEXT NOT NULL,
  duration_days INTEGER NOT NULL,
  fine_amount DOUBLE NOT NULL,
  checkout_date TEXT NOT NULL
);
--
--
-- ============================================================
-- STEP 2: LOAD DATA (PARENT FIRST, THEN CHILD)
-- ============================================================
-- DUCKDB SPECIFIC:
-- DuckDB allows us to load data from CSV files using the DuckDB COPY command.
--
-- The independent table must be loaded first.
-- In libraries, branches exist independently of the items they have.
-- Therefore, load the branch table before the checkout table.
--
-- SQLITE ALTERNATIVE:
-- If we used SQLite, we would load data using Python and pandas.
-- Load the parent (independent) table first.
COPY branch
FROM 'data/library/branch.csv'
(HEADER, DELIMITER ',', QUOTE '"', ESCAPE '"');

-- Load the child (dependent) table second.
COPY checkout
FROM 'data/library/checkout.csv'
(HEADER 1, DELIMITER ',', QUOTE '"', ESCAPE '"');

--
--
-- ============================================================
-- FINISH EXECUTION: ATOMIC BOOTSTRAP (ALL OR NOTHING)
-- ============================================================
-- If we reach this point, all operations succeeded.
-- Therefore, commit the transaction to make the changes permanent.
COMMIT;
--
--
-- ============================================================
-- REFERENCE: DUCKDB COPY CSV OPTIONS
-- ============================================================
-- CUSTOM: WHEN USING DUCKDB COPY COMMAND, the last line tells how to read the CSV file.
--
-- HEADER 1:
-- The first row in the CSV file contains column headers (not data).
-- Use HEADER 0 if no header row.
--
-- DELIMITER ',':
-- Columns are separated by commas.
--
-- QUOTE '"':
-- Text fields are enclosed in double quotes.
--
-- ESCAPE '"':
-- Double quotes within text fields are escaped by doubling them.
