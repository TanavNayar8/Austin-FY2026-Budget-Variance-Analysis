/*
PROJECT: Austin FY2026 Q3 Operating Budget
FILE: 02_Department_Variance.sql
PURPOSE: Department-level budget vs expenditure analysis.
*/

-- Aggregate department totals and sort by absolute variance to find the largest drivers
SELECT
    department_name,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(expenditures), 2) AS total_expenditure,
    ROUND(SUM(variance), 2) AS total_variance
FROM budget_cleaned
GROUP BY department_name
ORDER BY ABS(SUM(variance)) DESC;


-- Calculate variance percentage (excluding zero and negative budgets)
SELECT
    department_name,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(expenditures), 2) AS total_expenditure,
    ROUND(SUM(variance), 2) AS total_variance,
    ROUND((SUM(expenditures) - SUM(budget)) / NULLIF(SUM(budget), 0) * 100, 2) AS variance_pct
FROM budget_cleaned
WHERE budget_status = 'Positive Budget'
GROUP BY department_name
HAVING SUM(budget) > 0
ORDER BY ABS(SUM(variance)) DESC;


-- Create a reusable department-level analytical summary
WITH department_summary AS (
    SELECT
        department_name,
        SUM(budget) AS budget,
        SUM(expenditures) AS expenditure,
        SUM(variance) AS variance
    FROM budget_cleaned
    WHERE budget_status = 'Positive Budget'
    GROUP BY department_name
)
SELECT
    department_name,
    ROUND(budget, 2) AS total_budget,
    ROUND(expenditure, 2) AS total_expenditure,
    ROUND(variance, 2) AS total_variance,
    ROUND((variance / NULLIF(budget, 0)) * 100, 2) AS variance_pct
FROM department_summary
ORDER BY ABS(variance) DESC;


-- Rank departments by absolute variance
WITH department_summary AS (
    SELECT
        department_name,
        SUM(budget) AS budget,
        SUM(expenditures) AS expenditure,
        SUM(variance) AS variance
    FROM budget_cleaned
    WHERE budget_status = 'Positive Budget'
    GROUP BY department_name
)
SELECT
    RANK() OVER (ORDER BY ABS(variance) DESC) AS variance_rank,
    department_name,
    ROUND(budget, 0) AS total_budget,
    ROUND(expenditure, 0) AS total_expenditure,
    ROUND(variance, 0) AS total_variance,
    ROUND((variance / NULLIF(budget, 0)) * 100, 2) AS variance_pct
FROM department_summary
ORDER BY variance_rank;