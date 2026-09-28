/*
PROJECT: Austin FY2026 Q3 Operating Budget
FILE: 01_Data_Validation.sql
PURPOSE: QA checks post-import to verify row counts, financial totals, and accounting distributions.
*/

-- Check total row count to ensure full import
SELECT
    COUNT(*) AS total_rows
FROM budget_cleaned;


-- Validate financial totals against Power Query output
-- Expected Totals: Budget = $8.102B, Expenditures = $6.596B, Variance = -$1.506B
SELECT
    ROUND(SUM(budget),2) AS total_budget,
    ROUND(SUM(expenditures),2) AS total_expenditures,
    ROUND(SUM(variance),2) AS total_variance
FROM budget_cleaned;


-- Check distribution of budget statuses
-- Expected Counts: Positive = 29,485 | Zero = 26,803 | Negative = 1,242
SELECT
    budget_status,
    COUNT(*) AS reporting_lines,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_dataset
FROM budget_cleaned
GROUP BY budget_status
ORDER BY reporting_lines DESC;


-- Verify financial reporting patterns
-- Distinguishes standard budget lines from special accounting cases (zero-budget/negative-budget)
SELECT
    financial_pattern,
    COUNT(*) AS reporting_lines,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_dataset
FROM budget_cleaned
GROUP BY financial_pattern
ORDER BY reporting_lines DESC;