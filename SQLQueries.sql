
-- =========================================================
-- EMPLOYEE ATTRITION ANALYSIS
-- Dataset: IBM HR Analytics Employee Attrition & Performance
-- Tool: Google BigQuery
-- =========================================================


-- =========================================================
-- 1. DATA QUALITY ASSESSMENT
-- =========================================================

-- 1.1 Check for duplicate Employee IDs

SELECT
  COUNT(EmployeeNumber) AS TotalRows,
  COUNT(DISTINCT EmployeeNumber) AS UniqueRows
FROM
  `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`;


-- Check for missing Employee IDs

SELECT
  COUNT(*) AS MissingEmployeeIDs
FROM
  `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
WHERE
  EmployeeNumber IS NULL;


-- 1.2 Check for missing monthly income values

SELECT
  COUNT(*) AS MissingSalary
FROM
  `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
WHERE
  MonthlyIncome IS NULL;


-- 1.3 Check for environment satisfaction scores outside
-- the expected range of 1-4

SELECT
  COUNT(EnvironmentSatisfaction) AS InvalidScores
FROM
  `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
WHERE
  EnvironmentSatisfaction < 1
  OR EnvironmentSatisfaction > 4;


-- Check for missing environment satisfaction scores

SELECT
  COUNT(*) AS MissingSatisfactionScores
FROM
  `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
WHERE
  EnvironmentSatisfaction IS NULL;


-- 1.4 Check for employees whose years since last promotion
-- exceed their total years at the company

SELECT
  COUNT(*) AS InvalidPromotionHistory
FROM
  `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
WHERE
  YearsSinceLastPromotion > YearsAtCompany;


-- =========================================================
-- 2. EMPLOYEE ATTRITION ANALYSIS
-- =========================================================


-- 2.1 How does attrition vary by years since last promotion?
-- Employees are grouped into five promotion-history intervals.

WITH PromotionAnalysis AS (
  SELECT
    COUNT(*) AS EmployeeCount,
    CASE
      WHEN YearsSinceLastPromotion = 0 THEN '0 Years'
      WHEN YearsSinceLastPromotion <= 2 THEN '1-2 Years'
      WHEN YearsSinceLastPromotion <= 5 THEN '3-5 Years'
      WHEN YearsSinceLastPromotion <= 10 THEN '6-10 Years'
      WHEN YearsSinceLastPromotion <= 15 THEN '11-15 Years'
      ELSE 'Unknown'
    END AS PromotionGroup,
    SUM(
      CASE
        WHEN Attrition IS TRUE THEN 1
        ELSE 0
      END
    ) AS DepartedCount
  FROM
    `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
  GROUP BY
    PromotionGroup
)

SELECT
  PromotionGroup,
  EmployeeCount,
  DepartedCount,
  ROUND(DepartedCount * 100 / EmployeeCount, 2) AS AttritionPercentage
FROM
  PromotionAnalysis;


-- 2.2 Is employee salary associated with attrition?
-- Compare average monthly income for employees who stayed
-- versus employees who left.

SELECT
  COUNT(*) AS EmployeeCount,
  AVG(MonthlyIncome) AS AverageIncome,
  Attrition
FROM
  `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
GROUP BY
  Attrition;


-- 2.3 How do attrition percentages differ between employees
-- who work overtime and employees who do not?

WITH OverTimeAnalysis AS (
  SELECT
    COUNT(*) AS EmployeeCount,
    OverTime,
    SUM(
      CASE
        WHEN Attrition IS TRUE THEN 1
        ELSE 0
      END
    ) AS DepartedCount
  FROM
    `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
  GROUP BY
    OverTime
)

SELECT
  EmployeeCount,
  OverTime,
  DepartedCount,
  ROUND(DepartedCount / EmployeeCount * 100, 2) AS AttritionPercentage
FROM
  OverTimeAnalysis;


-- 2.4 Is environment satisfaction associated with attrition?
-- Compare attrition percentages across satisfaction scores 1-4.

WITH EnvironmentSatisfactionAnalysis AS (
  SELECT
    COUNT(*) AS EmployeeCount,
    CASE
      WHEN EnvironmentSatisfaction = 1 THEN 'Group 1'
      WHEN EnvironmentSatisfaction = 2 THEN 'Group 2'
      WHEN EnvironmentSatisfaction = 3 THEN 'Group 3'
      WHEN EnvironmentSatisfaction = 4 THEN 'Group 4'
      ELSE 'Unknown'
    END AS EnvironmentSatisfactionGroup,
    SUM(
      CASE
        WHEN Attrition IS TRUE THEN 1
        ELSE 0
      END
    ) AS DepartedCount
  FROM
    `project-110d2644-ef6b-475c-bd1.employee_data.employee_attrition`
  GROUP BY
    EnvironmentSatisfaction
)

SELECT
  EnvironmentSatisfactionGroup,
  EmployeeCount,
  DepartedCount,
  ROUND(DepartedCount * 100 / EmployeeCount, 2) AS AttritionPercentage
FROM
  EnvironmentSatisfactionAnalysis;
