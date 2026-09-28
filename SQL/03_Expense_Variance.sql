/*
PROJECT: Austin FY2026 Q3 Operating Budget
FILE: 03_Expense_Variance.sql
PURPOSE: Identify variance drivers by expense category and investigate distinct accounting patterns.
*/

-- Total budget vs expenditure by expense category
SELECT
    expense_name,
    ROUND(SUM(budget),2) AS total_budget,
    ROUND(SUM(expenditures),2) AS total_expenditure,
    ROUND(SUM(variance),2) AS total_variance
FROM budget_cleaned
GROUP BY expense_name
ORDER BY ABS(SUM(variance)) DESC;


-- Investigate zero-budget expenditure lines
SELECT
    expense_name,
    COUNT(*) AS reporting_lines,
    ROUND(SUM(expenditures),2) AS total_expenditure
FROM budget_cleaned
WHERE zero_budget_expenditure_flag = 'Yes'
GROUP BY expense_name
ORDER BY total_expenditure DESC;


-- Track negative expenditures (refunds, reimbursements, or accounting adjustments)
SELECT
    expense_name,
    COUNT(*) AS occurrences,
    ROUND(SUM(expenditures),2) AS total_negative_expenditure
FROM budget_cleaned
WHERE negative_expenditure_flag = 'Yes'
GROUP BY expense_name
ORDER BY total_negative_expenditure ASC;


-- Calculate % contribution to total city absolute variance by expense category
WITH expense_summary AS (
    SELECT
        expense_name,
        SUM(variance) AS variance
    FROM budget_cleaned
    GROUP BY expense_name
),
total_variance AS (
    SELECT SUM(ABS(variance)) AS city_variance FROM expense_summary
)
SELECT
    e.expense_name,
    ROUND(e.variance,2) AS variance,
    ROUND(ABS(e.variance) / NULLIF(t.city_variance,0) * 100, 2) AS contribution_pct
FROM expense_summary e
CROSS JOIN total_variance t 
ORDER BY contribution_pct DESC;


-- Identify the largest expense variance driver within each department
WITH expense_department AS (
    SELECT
        department_name,
        expense_name,
        SUM(variance) AS variance
    FROM budget_cleaned
    GROUP BY department_name, expense_name
),
ranked_expenses AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY department_name ORDER BY ABS(variance) DESC) AS rn
    FROM expense_department
)
SELECT
    department_name,
    expense_name,
    ROUND(variance,2) AS variance
FROM ranked_expenses
WHERE rn = 1
ORDER BY ABS(variance) DESC;