CREATE DATABASE RetailInventoryDB;
USE RetailInventoryDB;

-- Table to store supplier information
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    ContactInfo VARCHAR(500) NOT NULL
);

-- Table to store product information
CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    StockLevel INT NOT NULL DEFAULT 0 CHECK (StockLevel >= 0),
    SupplierID INT NOT NULL,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

-- Table to store customer information
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Address TEXT NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE
);

-- Table to store order information
CREATE TABLE `Order` (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Table to store order details (junction table between Order and Product)
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Trigger to update stock level after order
DELIMITER //
CREATE TRIGGER after_order_detail_insert
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    UPDATE Product 
    SET StockLevel = StockLevel - NEW.Quantity 
    WHERE ProductID = NEW.ProductID;
END//
DELIMITER ;

-- Trigger to update total amount in Order table
DELIMITER //
CREATE TRIGGER after_order_detail_insert_update_total
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    UPDATE `Order` 
    SET TotalAmount = TotalAmount + NEW.Subtotal 
    WHERE OrderID = NEW.OrderID;
END//
DELIMITER ;

-- Index for frequently queried columns
CREATE INDEX idx_product_category ON Product(Category);
CREATE INDEX idx_product_stock ON Product(StockLevel);
CREATE INDEX idx_order_date ON `Order`(OrderDate);
CREATE INDEX idx_customer_email ON Customer(Email);