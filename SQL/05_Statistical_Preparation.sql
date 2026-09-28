/*
PROJECT: Austin FY2026 Q3 Operating Budget
FILE: 05_Statistical_Preparation.sql
PURPOSE: Prepare aggregated department metrics for Excel statistical profiling (IQR, Mean, Median).
*/

-- Create the core analytical dataset for Excel export
SELECT
    department_name,
    COUNT(*) AS reporting_lines,
    ROUND(SUM(budget),2) AS total_budget,
    ROUND(SUM(expenditures),2) AS total_expenditure,
    ROUND(SUM(variance),2) AS variance_amount,
    ROUND(ABS(SUM(variance)),2) AS absolute_variance,
    ROUND(SUM(expenditures) / NULLIF(SUM(budget),0), 4) AS budget_utilization_ratio,
    ROUND((SUM(expenditures)-SUM(budget)) / NULLIF(SUM(budget),0) * 100, 2) AS variance_pct
FROM budget_cleaned
WHERE budget_status = 'Positive Budget'
GROUP BY department_name
HAVING SUM(budget) > 0
ORDER BY department_name;


-- Rank departments by budget utilization ratio
WITH department_stats AS (
    SELECT
        department_name,
        SUM(budget) AS budget,
        SUM(expenditures) AS expenditure
    FROM budget_cleaned
    WHERE budget_status = 'Positive Budget'
    GROUP BY department_name
)
SELECT
    RANK() OVER (ORDER BY expenditure / NULLIF(budget,0) DESC) AS utilization_rank,
    department_name,
    ROUND(budget,2) AS total_budget,
    ROUND(expenditure,2) AS total_expenditure,
    ROUND(expenditure / NULLIF(budget,0), 4) AS utilization_ratio
FROM department_stats
ORDER BY utilization_rank;