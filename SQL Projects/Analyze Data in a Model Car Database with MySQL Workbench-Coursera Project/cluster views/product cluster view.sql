-- Creates a view combining relevant data from a cluster of interelated tables including: Products, Order Details, Orders, and Warehouses
-- The query displays data for all products carried by the Mint Classics Company regardless of corresponding data from Order Details, Orders, or Warehouses
-- This approach allows for the aggregation of data across multiple dimensions for assessing product profitability and warehousing storage dynamics

CREATE OR REPLACE VIEW products_view AS
SELECT p.productCode,
p.productName,
p.productLine,
p.quantityInStock,
p.buyPrice,
coalesce(od.priceEach,0) AS priceEach,
coalesce((od.priceEach-p.buyPrice),0) AS profitPerItemOrder,
coalesce(od.quantityOrdered,0)AS quantityOrdered,
coalesce(((od.priceEach-p.buyPrice)*od.quantityOrdered),0) AS profitPerOrder,
od.orderNumber,
o.orderDate,
o.shippedDate,
o.status,
w.warehouseCode,
w.warehouseName
FROM products pproducts_view
LEFT JOIN orderdetails od ON od.productCode=p.productCode
LEFT JOIN orders o ON o.orderNumber=od.orderNumber
LEFT JOIN warehouses w on w.warehouseCode=p.warehouseCode
;

