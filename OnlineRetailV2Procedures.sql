USE RetailInventoryDBv2;

DELIMITER //

CREATE PROCEDURE AddCustomer(
	IN custName VARCHAR(255),
	IN custEmail VARCHAR(255),
    IN custAddress TEXT,
    IN custPhone VARCHAR(20)
)
BEGIN
	INSERT INTO Customer (Name, Email, Address, Phone)
    VALUES(custName, custEmail, custAddress, custPhone);
END //

CREATE PROCEDURE AddNewProduct(
    IN p_Name VARCHAR(255),
    IN p_Category VARCHAR(100),
    IN p_Price DECIMAL(10, 2),
    IN p_StockLevel INT,
    IN p_SupplierID INT
)
BEGIN
    INSERT INTO Product (Name, Category, Price, StockLevel, SupplierID)
    VALUES (p_Name, p_Category, p_Price, p_StockLevel, p_SupplierID);
END //

CREATE PROCEDURE UpdateProductStock(
    IN p_ProductID INT,
    IN p_Quantity INT
)
BEGIN
    UPDATE Product
    SET StockLevel = StockLevel + p_Quantity
    WHERE ProductID = p_ProductID;
END //


DELIMITER ;