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
CALL AddCustomer('Robin Hood', 'robin@hood.com', '31 Poker St', '123-456-7890');
CALL UpdateProductStock(101, 20);



SELECT * FROM Customer;

