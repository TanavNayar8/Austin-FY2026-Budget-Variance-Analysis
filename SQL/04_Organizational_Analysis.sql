/*
PROJECT: Austin FY2026 Q3 Operating Budget
FILE: 04_Organizational_Analysis.sql
PURPOSE: Variance analysis across organizational hierarchies (Rollups, Funds, Programs, Departments).
*/

-- Rollup Level Summary
SELECT
    dept_rollup_name,
    COUNT(DISTINCT department_name) AS departments,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(expenditures), 2) AS total_expenditure,
    ROUND(SUM(variance), 2) AS total_variance
FROM budget_cleaned
WHERE budget_status = 'Positive Budget'
GROUP BY dept_rollup_name
ORDER BY ABS(SUM(variance)) DESC;


-- Fund Level Summary
SELECT
    fund_name,
    COUNT(DISTINCT department_name) AS departments,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(expenditures), 2) AS total_expenditure,
    ROUND(SUM(variance), 2) AS total_variance
FROM budget_cleaned
WHERE budget_status = 'Positive Budget'
GROUP BY fund_name
ORDER BY ABS(SUM(variance)) DESC;


-- Program Level Summary
SELECT
    program_name,
    COUNT(DISTINCT department_name) AS departments,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(expenditures), 2) AS total_expenditure,
    ROUND(SUM(variance), 2) AS total_variance
FROM budget_cleaned
WHERE budget_status = 'Positive Budget'
GROUP BY program_name
ORDER BY ABS(SUM(variance)) DESC;


-- Department × Expense Analysis
SELECT
    department_name,
    expense_name,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(expenditures), 2) AS total_expenditure,
    ROUND(SUM(variance), 2) AS total_variance
FROM budget_cleaned
WHERE budget_status = 'Positive Budget'
GROUP BY department_name, expense_name
ORDER BY ABS(SUM(variance)) DESC;


-- Drill down: Largest Department x Expense combinations
WITH department_expense AS (
    SELECT
        department_name,
        expense_name,
        SUM(budget) AS budget,
        SUM(expenditures) AS expenditure,
        SUM(variance) AS variance
    FROM budget_cleaned
    WHERE budget_status = 'Positive Budget'
    GROUP BY department_name, expense_name
)
SELECT
    department_name,
    expense_name,
    ROUND(budget, 2) AS total_budget,
    ROUND(expenditure, 2) AS total_expenditure,
    ROUND(variance, 2) AS total_variance,
    ROUND(variance / NULLIF(budget, 0) * 100, 2) AS variance_pct
FROM department_expense
ORDER BY ABS(variance) DESC
LIMIT 25;


-- SPECIAL ACCOUNTING PATTERNS:
-- Isolate expenditures recorded on zero-budget lines by department
SELECT
    department_name,
    COUNT(*) AS reporting_lines,
    ROUND(SUM(expenditures), 2) AS expenditure_without_budget
FROM budget_cleaned
WHERE zero_budget_expenditure_flag = 'Yes'
GROUP BY department_name
ORDER BY expenditure_without_budget DESC;


-- Isolate negative budget allocations by department
SELECT
    department_name,
    COUNT(*) AS reporting_lines,
    ROUND(SUM(budget), 2) AS total_negative_budget
FROM budget_cleaned
WHERE negative_budget_flag = 'Yes'
GROUP BY department_name
ORDER BY total_negative_budget ASC;


-- Isolate negative expenditure records by department
SELECT
    department_name,
    COUNT(*) AS reporting_lines,
    ROUND(SUM(expenditures), 2) AS total_negative_expenditure
FROM budget_cleaned
WHERE negative_expenditure_flag = 'Yes'
GROUP BY department_name
ORDER BY total_negative_expenditure ASC;