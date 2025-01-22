CREATE OR REPLACE VIEW customers_view AS
with order_totals AS
(
SELECT o.orderNumber,o.customerNumber,sum(od.quantityOrdered*od.priceEach) AS totalOrderAmount
FROM orders o
JOIN orderdetails od
ON o.orderNumber=od.orderNumber
GROUP BY o.orderNumber,o.customerNumber
),
aggregated_payments AS
(
SELECT p.customerNumber,SUM(p.amount) AS totalPayments,MAX(p.paymentDate) AS latestPaymentDate
FROM payments p
GROUP BY p.customerNumber
)
SELECT c.customerNumber,c.customerName,c.city,c.country,
c.creditLimit,c.salesRepEmployeeNumber,e.lastName,e.firstName,
ot.orderNumber,o.orderDate,o.shippedDate,o.status,
ap.latestPaymentDate,coalesce(ap.totalPayments,0) AS totalPayments,ot.totalOrderAmount
FROM customers c
LEFT JOIN employees e
ON c.salesRepEmployeeNumber=e.employeeNumber
LEFT JOIN orders o
ON o.customerNumber=c.customerNumber
LEFT JOIN order_totals ot
ON ot.orderNumber=o.orderNumber
LEFT JOIN aggregated_payments ap
ON c.customerNumber=ap.customerNumber
GROUP BY c.customerNumber,c.customerName,c.city,c.country,
c.creditLimit,c.salesRepEmployeeNumber,e.lastName,e.firstName,
ot.orderNumber,o.orderDate,o.shippedDate,o.status,
ap.latestPaymentDate,ot.totalOrderAmount;
