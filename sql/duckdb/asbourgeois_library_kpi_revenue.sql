-- sql/duckdb/asbourgeois_retail_kpi_revenue.sql
-- ============================================================
-- PURPOSE
-- ============================================================
-- Calculate a Key Performance Indicator (KPI) for the retail domain using DuckDB SQL.
--
-- KPI DRIVES THE WORK:
-- In analytics, we do not start with "write a query."
-- We start with a KPI that supports an actionable decision.
--
-- ACTIONABLE OUTCOME (EXAMPLE):
-- We want to identify which branches have the longest time items are checked out to:
-- - ensure that items are being used,
-- - check to see if there is a need for something in particular,
-- - investigate why certain materials are not being used.
--
-- In this problem, our KPI is duration days (total amount of days an item is checked out) by branch.
--
-- ANALYST RESPONSIBILITY:
-- Analysts are responsible for determining HOW to get the information
-- that informs the KPI and supports action.
-- That means:
-- - identifying the needed tables,
-- - joining them correctly,
-- - selecting the right measures,
-- - aggregating at the correct level (store),
-- - and presenting results in a way that supports decision-making.
--
-- ASSUMPTION:
-- We always run all commands from the project root directory.
--
-- EXPECTED PROJECT PATHS (relative to repo root):
--   SQL:  sql/duckdb/asbourgeois_library_kpi_revenue.sql
--   DB:   artifacts/duckdb/library.duckdb
--
--
-- ============================================================
-- TOPIC DOMAINS + 1:M RELATIONSHIPS
-- ============================================================
-- OUR DOMAIN: LIBRARY
-- Two tables in a 1-to-many relationship (1:M):
-- - branch (1): independent/parent table
-- - checkout  (M): dependent/child table
--
-- HOW THIS RELATES TO OUR KPI:
-- - The branch table tells us "which branch" (branch_id, branch_name, city).
-- - The checkout table contains the measurable activity (material type, duration of checkout, fine amount).
-- - To compute duration days by branch, we must:
--   1) connect each checkout to its branch (JOIN on branch_id),
--   2) aggregate duration days at the branch level (GROUP BY branch).
--
--
-- ============================================================
-- KPI DEFINITION
-- ============================================================
-- KPI NAME: Total Duration of Items Being Checked Out By Branch
-- MEASURE:
-- - amount_days = SUM(checkout.duration_days)
--
-- GRAIN (LEVEL OF DETAIL):
-- - one row per branch
--
-- OUTPUT (WHAT DECISION-MAKERS NEED):
-- - branch identifier and name
-- - total amount of days
--
--
-- ============================================================
-- EXECUTION: GET THE INFORMATION THAT INFORMS THE KPI
-- ============================================================
-- Strategy:
-- - JOIN branch (1) to checkout (M)
-- - GROUP BY branch
-- - SUM duration_days to compute amount_days
-- - ORDER results so we can quickly see top branches
--
SELECT
  s.branch_id,
  s.branch_name,
  s.city,
  s.system_name,
  COUNT(sa.checkout_id) AS checkout_count,
  ROUND(SUM(sa.duration_days), 2) AS total_amount_days,
FROM branch AS s
JOIN checkout AS sa
  ON sa.branch_id = s.branch_id
GROUP BY
  s.branch_id,
  s.branch_name,
  s.city,
  s.system_name
ORDER BY total_amount_days DESC;
