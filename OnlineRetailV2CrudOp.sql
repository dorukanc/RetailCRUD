USE RetailInventoryDBv2;

-- 1. CREATE: Add a new customer
INSERT INTO Customer (Name, Email, Address, Phone)
VALUES ('Dorukan', 'catakd@mef.edu.tr', '123 New Street, New York, NY 00201', '1234212193');

-- 2. CREATE: Place a new order with multiple products
-- First, create the order
INSERT INTO `Order` (CustomerID, Status, PaymentStatus)
VALUES (2, 'Processing', 'Pending');

-- Then, add order details (the triggers will handle subtotal and total calculations)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES 
    (LAST_INSERT_ID(), 1, 6),  -- 2 units of Product ID 1
    (LAST_INSERT_ID(), 3, 1);  -- 1 unit of Product ID 3

-- 3. READ: Get all orders for a specific customer with product details
SELECT 
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    o.Status,
    p.Name AS ProductName,
    od.Quantity,
    od.Subtotal
FROM `Order` o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Product p ON od.ProductID = p.ProductID
WHERE o.CustomerID = 1
ORDER BY o.OrderDate DESC;

-- 4. READ: Find products with low stock (less than 10 units)
SELECT 
    p.ProductID,
    p.Name,
    p.Category,
    p.StockLevel,
    s.Name AS SupplierName,
    s.ContactPerson,
    s.Phone
FROM Product p
JOIN Supplier s ON p.SupplierID = s.SupplierID
WHERE p.StockLevel < 10
ORDER BY p.StockLevel ASC;

-- 5. UPDATE: Update customer contact information
UPDATE Customer
SET 
	Name = 'Tony Stark',
    Email = 'ironman@starkindustries.com',
    Phone = '5673411320',
    Address = '456 Updated Ave, New York, NY 60601',
    UpdatedAt = CURRENT_TIMESTAMP
WHERE CustomerID = 1;

-- 6. UPDATE: Modify product price and update stock level
UPDATE Product
SET 
    Price = 749.99,
    StockLevel = StockLevel + 25,
    UpdatedAt = CURRENT_TIMESTAMP
WHERE ProductID = 1;

-- 7. READ: Generate a sales report by category
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

-- 8. UPDATE: Change order status and payment status
UPDATE `Order`
SET 
    Status = 'Shipped',
    PaymentStatus = 'Paid',
    UpdatedAt = CURRENT_TIMESTAMP
WHERE OrderID = 1;

-- 9. DELETE: Cancel an order (only if it's still pending)
DELETE FROM OrderDetails 
WHERE OrderID = (
    SELECT OrderID 
    FROM `Order` 
    WHERE OrderID = 1 
    AND Status = 'Pending'
);

DELETE FROM `Order`
WHERE OrderID = 1 
AND Status = 'Pending';

-- 10. READ: Find top customers by total purchase amount
SELECT 
    c.CustomerID,
    c.Name,
    c.Email,
    COUNT(DISTINCT o.OrderID) as TotalOrders,
    SUM(o.TotalAmount) as TotalSpent
FROM Customer c
JOIN `Order` o ON c.CustomerID = o.CustomerID
WHERE o.Status != 'Cancelled'
GROUP BY c.CustomerID, c.Name, c.Email
ORDER BY TotalSpent DESC
LIMIT 10;