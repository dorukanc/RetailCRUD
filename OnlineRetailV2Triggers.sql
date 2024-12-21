USE RetailInventoryDBv2;

DELIMITER //

-- Trigger to calculate subtotal before inserting OrderDetails
CREATE TRIGGER before_orderdetail_insert 
BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE product_price DECIMAL(10,2);
    
    -- Get the product price
    SELECT Price INTO product_price 
    FROM Product 
    WHERE ProductID = NEW.ProductID;
    
    -- Calculate subtotal
    SET NEW.Subtotal = product_price * NEW.Quantity;
END//

-- Trigger to update Order total amount after inserting OrderDetails
CREATE TRIGGER after_orderdetail_insert
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    -- Update the total amount in Order table
    UPDATE `Order` 
    SET TotalAmount = (
        SELECT SUM(Subtotal)
        FROM OrderDetails
        WHERE OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END//

-- Trigger to calculate subtotal before updating OrderDetails
CREATE TRIGGER before_orderdetail_update
BEFORE UPDATE ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE product_price DECIMAL(10,2);
    
    -- Get the product price
    SELECT Price INTO product_price 
    FROM Product 
    WHERE ProductID = NEW.ProductID;
    
    -- Calculate new subtotal
    SET NEW.Subtotal = product_price * NEW.Quantity;
END//

-- Trigger to update Order total amount after updating OrderDetails
CREATE TRIGGER after_orderdetail_update
AFTER UPDATE ON OrderDetails
FOR EACH ROW
BEGIN
    -- Update the total amount in Order table
    UPDATE `Order` 
    SET TotalAmount = (
        SELECT SUM(Subtotal)
        FROM OrderDetails
        WHERE OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END//

-- Trigger to check stock availability before inserting OrderDetails
CREATE TRIGGER before_orderdetail_insert_check_stock
BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    
    -- Get the current stock level
    SELECT StockLevel INTO available_stock
    FROM Product 
    WHERE ProductID = NEW.ProductID;
    
    -- Check if there's enough stock
    IF available_stock < NEW.Quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock available for this order';
    END IF;
END//

-- Trigger to update stock level after inserting OrderDetails
CREATE TRIGGER after_orderdetail_insert_update_stock
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    -- Update the stock level in Product table
    UPDATE Product 
    SET StockLevel = StockLevel - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END//

-- Trigger to check stock availability before updating OrderDetails
CREATE TRIGGER before_orderdetail_update_check_stock
BEFORE UPDATE ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    DECLARE stock_difference INT;
    
    -- Get the current stock level
    SELECT StockLevel INTO available_stock
    FROM Product 
    WHERE ProductID = NEW.ProductID;
    
    -- Calculate the difference in quantity
    SET stock_difference = NEW.Quantity - OLD.Quantity;
    
    -- Check if there's enough stock for the update
    IF (available_stock < stock_difference) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock available for this order update';
    END IF;
END//

-- Trigger to update stock level after updating OrderDetails
CREATE TRIGGER after_orderdetail_update_update_stock
AFTER UPDATE ON OrderDetails
FOR EACH ROW
BEGIN
    -- Update the stock level in Product table
    UPDATE Product 
    SET StockLevel = StockLevel - (NEW.Quantity - OLD.Quantity)
    WHERE ProductID = NEW.ProductID;
END//

-- Trigger to restore stock level after deleting OrderDetails
CREATE TRIGGER after_orderdetail_delete_restore_stock
AFTER DELETE ON OrderDetails
FOR EACH ROW
BEGIN
    -- Restore the stock level in Product table
    UPDATE Product 
    SET StockLevel = StockLevel + OLD.Quantity
    WHERE ProductID = OLD.ProductID;
END//

DELIMITER ;