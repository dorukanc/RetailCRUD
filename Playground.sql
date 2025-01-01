USE RetailInventoryDBv2;

# Write a SQL Query to generate a report showing each supplier along with the names and stock levels of products they supply, only for products with stock level less than 10?
SELECT 
	s.SupplierID,
    s.Name AS SupplierName,
    p.ProductID,
    p.Name AS ProductName,
    p.StockLevel
FROM Supplier s
JOIN Product p ON s.SupplierID = p.SupplierID
WHERE
	p.StockLevel < 50
ORDER BY
	p.StockLevel ASC;


SELECT * FROM `Order`
WHERE OrderID = 1; 

SELECT * FROM OrderDetails
WHERE OrderID = 2;

SELECT * FROM Product
WHERE ProductID = 1;

CREATE VIEW Sales_Report AS 
SELECT 
    p.Category,
    COUNT(DISTINCT o.OrderID) as TotalOrders,
    SUM(od.Quantity) as TotalUnitsSold,
    SUM(od.Subtotal) as TotalRevenue
FROM Product p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN `Order` o ON od.OrderID = o.OrderID
WHERE o.Status != 'Cancelled'
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

SELECT * FROM Sales_Report;

SELECT * FROM Product;
# call procedures
CALL AddCustomer('Tijd Bahar', 'tj@hood.com', '32 Poker St', '123-486-7890');

CALL UpdateProductStock(101, 20);



SELECT * FROM `Order`;

DELETE FROM Customer
WHERE CustomerID = 44;

