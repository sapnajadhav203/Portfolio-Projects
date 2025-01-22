

-- Creates a view combining relevant data from a cluster of tables including: Employees, Offices, and Customers
-- This approach allows for the aggregation of data across multiple dimensions for assessing geographic analysis, managerial structure, and customer management
-- This view captures data for all employees of the Mint Classics company and as such should contain null values for top-level executives or employees not currently managing customer

CREATE OR REPLACE VIEW employees_view AS
SELECT e.employeeNumber,
e.lastName,
e.firstName,
e.jobTitle,
e.reportsTo,
m.firstName AS managerFirstName,
m.lastName AS managerLastName,
o.officeCode,
o.city AS officeCity,
o.state AS officeState,
o.country AS officeCountry,
c.customerNumber,
c.customerName,
c.city AS customerCity,
c.state AS customerState,
c.country AS customerCountry
FROM 
    employees e
LEFT JOIN 
	employees m
ON m.employeeNumber=e.reportsTo
INNER JOIN
	Offices o
ON e.officeCode=o.officeCode
LEFT JOIN 
	customers c
ON e.employeeNumber=c.salesRepEmployeeNumber;