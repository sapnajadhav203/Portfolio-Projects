-------------------------------------------------------------------- Exploratory Data Analysis for Employees Cluster ----------------------------------------------------------------------------------
----------------- The Employees Cluster View contains data pertaining to all employees of the Mint Classics Company joining rows across the Employees, Offices, and Customers tables ------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------- Employee Statistics ------------------------------------------------------------------------------------------
-- How many people work at Mint Classics
SELECT COUNT(distinct(employeeNumber)) AS totalEmployees 
FROM employees_view;              -- There are 23 employees working at MintClassics company

SELECT jobTitle,COUNT(distinct(employeeNumber))AS totalEmployees 
FROM employees_view
GROUP BY jobTitle
ORDER BY totalEmployees DESC;
-- Of the 23 employees at Mint Classics most (17) are Sales Reps 

-- List of Employees with No Assigned Customers
SELECT employeeNumber,lastName,firstName,jobTitle
FROM employees_view
where customerNumber IS NULL;
-- 6 out of the 8 returned employees occupy upper-management positions including the President, VP of Sales, VP of Marketing, and sales managers three major regions: (APAC), (NA), and (EMEA)
-- Sales Reps Tom King and Yoshimi Kato are currently not handling any customers

-------------------------------------------------------------------------------- Geographic Analysis ------------------------------------------------------------------------------------------------
-- Employees Without Assigned Offices
SELECT employeeNumber,lastName,firstName,jobTitle
FROM employees_view
where officeCode IS NULL;
-- Empty Set: All employees of the Mint Classics Company are currently assigned to an office location

-- Employees by Country
SELECT officeCountry,count(DISTINCT(employeeNumber)) AS totalEmployees
FROM employees_view
GROUP BY officeCountry
ORDER BY totalEmployees DESC;
-- Japan and UK has the fewest employees at 2 while the U.S. has the most at 10

-- Customers Managed by Office Location
SELECT officeCity,officeCountry,count(customerNumber) AS totalCustomers
FROM employees_view
WHERE customerNumber IS NOT NULL
GROUP BY officeCity,officeCountry
ORDER BY totalCustomers DESC;
 -- At 29 customers Paris represents a key market for business
-- With 3 major city locations the U.S. boasts a strong presence managing a total of 39 customers
-- However, the Sydney and Tokyo markets may present opportunities for growth having relatively lower customer counts (10 and 5, respectively)

-- Customers by Customer Location
SELECT customerCountry,count(customerNumber) AS totalCustomers
FROM employees_view
WHERE customerNumber IS NOT NULL
GROUP BY customerCountry
ORDER BY totalCustomers DESC;
-- Most number of customers are from USA country followed by France and spain so there can be new offices
-- Hongkong,Philippines and Ireland markets may present opportunities for growth having relatively lower customer counts(1)
----------------------------------------------------------------------------------- Managerial Structure --------------------------------------------------------------------------------------------
-- Rank manager by the number of most direct reports

SELECT  e.employeeNumber AS managerID,
e.lastName AS managerLastName,
e.firstName AS managerFirstName,
e.jobTitle AS managerJobTitle,
count(ev.employeeNumber) AS totalReportCount
FROM employees_view ev
JOIN employees_view e
ON e.employeeNumber=ev.reportsTo
GROUP BY e.employeeNumber,e.lastName,e.firstName,e.jobTitle
ORDER BY totalReportCount DESC ;
-- Gerard Bondur 'Sales Manager (EMEA)' is responsible for the most employees with a total of 46

-- Count of Customers Managed by Each Employee
SELECT employeeNumber,lastName,firstName,jobTitle,COUNT(customerNumber) AS totalCustomers
FROM employees_view
GROUP BY employeeNumber,lastName,firstName,jobTitle
ORDER BY totalCustomers DESC;

-- Sales Rep Pamela Castillo manages the most customers at 10
-- Of Sales Reps that manage customers Andy Fixter, Peter Marsh, and Mami Nishi all handle the least at 5 whereas Sales Reps Yashimi Kato manage 0 customers.

