-- sql/duckdb/asbourgeois_library_query_fine_aggregate.sql
-- ============================================================
-- PURPOSE
-- ============================================================
-- Summarize overall fine activity across ALL stores.
--
-- This query answers:
-- - "What is our total revenue from fines?"
-- - "What is the average fine amount?"
--
-- WHY:
-- - Establishes system-wide performance
-- - Provides a baseline before breaking results down by store
-- - Helps answer:
--   "Are items that are being checkout returned on time?"

SELECT
  COUNT(*) AS total_fine_count,
  ROUND(SUM(fine_amount), 2) AS total_fine,
  ROUND(AVG(fine_amount), 2) AS avg_fine_amount
FROM checkout;
