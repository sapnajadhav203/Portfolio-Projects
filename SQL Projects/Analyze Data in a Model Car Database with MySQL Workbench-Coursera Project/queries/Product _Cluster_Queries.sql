
-- Number of products sold by Mint Classics company
SELECT COUNT(*) FROM products; -- There are 110 products for sale

-- Number of total products in stock
SELECT SUM(quantityInStock) FROM products; -- There are 555131 products in stock across 4 warehouses(a,b,c,d) and 7 product lines(classic cars,motorcycles,planes,ships,trains,trucks and buses,vintage cars)


-- Is every product assigned to atleast one product line
SELECT * FROM products  
WHERE productLine IS NULL; -- Empty set : all products are assign to a product line

-- Are there any products that are not stored in Mint Classic Warehouses
SELECT * FROM products_view
WHERE warehouseCode IS NULL; -- Empty set: all products are stored in at least one of the Mint Classis Warehouses.

-- Are there any products not being purchased,i.e, has no corresponding data from the Order Details table, e.g, orderNumber is null, priceEach = 0, quantityOrdered = 0
SELECT * FROM products_view
WHERE ordernumber IS NULL and quantityordered=0; -- The 1985 Toyota Supra (productCode# S18_3233) currently has no sales, 7733 items in stock , and is stored in warehouse 'b'

----------------------------------------------------------------------------------- Space Utilization -----------------------------------------------------------------------------------------------
----------------------- All stock quantities represent static values for the time period 2003-01-10 to 2005-05-19, which are the dates of the first and last completed orders -----------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- Rank warehouses by the quantity of items in stock and show their current fill capacity
SELECT pc.warehousecode,pc.warehousename,sum(distinct pc.quantityinstock) as quantityInStock,w.warehousePctCap
FROM products_view pc
INNER JOIN warehouses w
ON pc.warehousecode=w.warehouseCode 
GROUP BY pc.warehousecode
ORDER BY quantityInStock desc;
-- The East warehouse 'B' has the most items in stock at 219,183 units while the South warehouse 'D' has the least at 79,380 units;they are 67% full and 75% full, respectively
-- The sum of stock totals across all warehouses equals 555,131 units

-- Calculates total revenue and total items ordered for each product line: Filtered for completed orders ('Shipped', Resolved','Disputed')
SELECT productline,SUM(quantityOrdered)AS quantityOrdered,sum(priceEach*quantityOrdered)AS totalRevenue,warehouseCode
FROM products_view 
WHERE status IN('Shipped','Resolved','Disputed')
GROUP BY productline,warehouseCode
ORDER BY totalRevenue DESC;
-- The results of this query show that product lines are not distributed, but stored in distinct warehouses  
-- A: 'Motorcycles' and 'Planes', B: 'Classic Cars', C: 'Vintage Cars', and D: 'Trucks and Buses', 'Ships', and 'Trains'
-- 'Classic Cars' is both the most ordered and highest selling product line moving 33,817 units and generating $3,670,560.34 in sales
-- 'Trains' is both the least ordered and lowest selling product line with 2,651 units shipped and $175,030.77 in sales
-- The total revenue for all completed orders comes out to $9,060,489.30 while the total orders are 99,398 units


-- Cumulative Product Turnover Rate: Filtered for completed orders ('Shipped', 'Resolved','Disputed')
SELECT productCode,productName,
SUM(quantityOrdered)/SUM(DISTINCT quantityInStock) AS inventoryTurnover
FROM products_view
WHERE status IN('Shipped','Resolved','Disputed')
group by productCode,productName
ORDER BY inventoryTurnover DESC;
-- The '1960 BSA Gold Star DBD34', '1968 Ford Mustang', '1928 Ford Phaeton Deluxe', and '1997 BMW F650 ST' are on the high end of inventory turnover
-- They have a turnover rate of 67.6667, 13.3676, 6.2206, and 5.1685 respectively suggesting high demand
-- Nearly 100 products have a turnover rate of less than 1


-- Cumulative Warehouse Turnover Rate: Filtered for completed orders ('Shipped', 'Resolved','Disputed')
SELECT warehouseCode,warehouseName,
SUM(quantityOrdered)/SUM(distinct quantityInStock) AS inventoryTurnover
FROM products_view
WHERE status IN('Shipped','Resolved','Disputed')
GROUP BY warehouseCode,warehouseName
ORDER BY inventoryTurnover DESC;
-- Rates are as follows - D: '0.2602', A: '0.1786', C: '0.1714', and B: '0.1599'

-------------------------------------------------------------------------------------- Summary Statistics -------------------------------------------------------------------------------------------
-- Determine which products are candidates for discontinuation by filtering for low sales, high stock, and low to moderate orders
SELECT pv.productCode,pv.productName,SUM(pv.QuantityInStock) AS quantityInStock,
MIN(pv.quantityOrdered)as quantityOrdered ,
MIN(pv.priceEach*pv.quantityOrdered) AS totalSales
from products_view pv
right join products p
on p.productCode=pv.productCode
WHERE status IN ('Shipped', 'Resolved','Disputed')
group by pv.productCode
ORDER BY quantityInStock desc,quantityOrdered asc,totalSales asc
;


WITH product_distribution AS
(
SELECT productCode,
productName,
sum(quantityOrdered) AS totalOrdered,
sum(priceEach*quantityOrdered) AS totalSales
FROM products_view
WHERE status IN('Shipped','Resolved','Disputed')
GROUP BY productCode,productName
),
products_stock as
(
SELECT productCode,productName,quantityInStock as TotalStock 
FROM products
),
quartiles as
(
SELECT ps.productCode,
ps.productName,
ps.totalstock AS totalStock,
coalesce(pd.totalordered,0) AS totalOrdered,
coalesce(pd.totalsales,0) AS totalSales,
NTILE(4)over(order by ps.totalstock)as quartilesTotalStock,
NTILE(4)over(order by pd.totalordered)as quartilesTotalOrdered,
NTILE(4)over(order by pd.totalsales)as quartilesTotalSales
from product_distribution pd
RIGHT JOIN products_stock ps
on ps.productCode=pd.productCode
)
select * from quartiles where quartilesTotalStock=4 and quartilesTotalOrdered<=2 and quartilesTotalSales=1;

-- Five candidates for discontinuation: '1985 Toyota Supra', '1966 Shelby Cobra 427 S/C', '1982 Lamborghini Diablo', '1982 Ducati 996 R', and '1950's Chicago Surface Lines Streetcar'
-- Together they account for 41,495 items in stock, 3,499 ordered items, and $152,430.94 in sales


-- Determine which products are candidates for a stock increase by filtering for high profit, low stock, and moderate to high demand
-- Assigns a quartile range to a given product over 3 dimensions: 'totalStock', 'totalOrdered', and 'totalProfit'
-- Filtered for completed orders ('Shipped', 'Resolved', 'Disputed')
WITH product_distribution AS
(
SELECT productCode,
productName,
sum(quantityOrdered) AS totalOrdered,
sum(priceEach*quantityOrdered) AS totalSales
FROM products_view
WHERE status IN('Shipped','Resolved','Disputed')
GROUP BY productCode,productName
),
products_stock as
(
SELECT productCode,productName,quantityInStock as TotalStocks 
FROM products
),
quartiles as
(
SELECT pd.productCode,
pd.productName,
ps.totalStocks,
COALESCE(pd.totalOrdered, 0) AS totalOrdered,
COALESCE(pd.totalSales, 0) AS totalSales,
NTILE(4)over(order by ps.totalstocks)as quartilesTotalStock,
NTILE(4)over(order by pd.totalordered)as quartilesTotalOrdered,
NTILE(4)over(order by pd.totalsales)as quartilesTotalSales
from product_distribution pd
RIGHT JOIN products_stock ps
on ps.productCode=pd.productCode
)
select * from quartiles where quartilestotalstock=1 and quartilestotalOrdered>=2 and quartilestotalsales>=4;


-- Outlier Detection - Detect outliers for the products distribution over 3 different dimensions by calculating their interquartile ranges and establishing upper and lower bounds for each
-- Filtered for completed orders ('Shipped', 'Resolved', 'Disputed')

WITH product_order_sales AS(
SELECT productCode,
productName , -- 1. Create table that calculates each products total orders and total sales for all completed orders
SUM(quantityOrdered) AS totalOrdered,
SUM(priceEach*quantityOrdered) AS totalSales
from products_view
WHERE status IN('Shipped','Resolved','Disputed')
GROUP BY productCode,productName
order by totalOrdered
),
-- 2. Create table that returns each products stock quantity regardless of order status
 product_stock AS(
SELECT productCode,ProductName,
SUM(quantityInStock) AS totalStock
FROM products
GROUP BY productCode,productName
),
-- 3. Join the previous 2 tables to include all products and impute potential null values for totalOrdered and totalSales with 0
products_distribution AS(
SELECT ps.productCode,
ps.productName,
ps.totalStock, ROW_NUMBER() OVER(ORDER BY totalstock) AS indexStock,
coalesce(pos.totalOrdered,0) AS totalOrdered,ROW_NUMBER() OVER(ORDER BY totalOrdered) AS indexOrdered,
coalesce(pos.totalSales,0) AS totalSales,ROW_NUMBER() OVER(ORDER BY totalSales) AS indexSales
FROM product_stock ps
LEFT JOIN product_order_sales pos
ON ps.productCode=pos.productCode
GROUP BY ps.productCode,ps.productName
),
 -- select * from product_distribution;
-- 4. Calculate statistics for each distribution: min, max, mean, q1, q2, q3, iqr

product_stats AS(
SELECT 
MIN(totalStock) AS minStock,MAX(totalStock) AS maxStock,
(SELECT totalStock FROM products_distribution WHERE indexstock=28)AS Q1_stock,(SELECT totalStock FROM products_distribution WHERE indexStock = 83) AS Q3_Stock,
(SELECT totalStock FROM products_distribution WHERE indexStock = 83) - (SELECT totalStock FROM products_distribution WHERE indexStock = 28) AS IQR_Stock,
MIN(totalOrdered) AS minOrdered, MAX(totalOrdered) AS maxOrdered,
(SELECT totalOrdered FROM products_distribution WHERE indexOrdered=28)AS Q1_Ordered,(SELECT totalOrdered FROM products_distribution WHERE indexOrdered = 83) AS Q3_Ordered,
(SELECT totalOrdered FROM products_distribution WHERE indexOrdered = 83) - (SELECT totalOrdered FROM products_distribution WHERE indexOrdered = 28) AS IQR_Ordered,
MIN(totalSales) AS minSales, MAX(totalSales) AS maxSales,
(SELECT totalSales FROM products_distribution WHERE indexSales=28)AS Q1_Sales,(SELECT totalSales FROM products_distribution WHERE indexSales = 83) AS Q3_Sales,
(SELECT totalSales FROM products_distribution WHERE indexSales = 83) - (SELECT totalSales FROM products_distribution WHERE indexSales = 28) AS IQR_Sales
    
    FROM products_distribution
)
select * from product_stats;
-- select * from products;
