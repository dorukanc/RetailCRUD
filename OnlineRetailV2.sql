CREATE DATABASE RetailInventoryDBv2;
USE RetailInventoryDBv2;

-- Table to store customer information with email and phone validation
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Address TEXT NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Status ENUM('Active', 'Inactive', 'Blocked') DEFAULT 'Active',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_email CHECK (Email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_phone CHECK (Phone REGEXP '^[0-9+-]{10,15}$'),
    UNIQUE (Email),
    UNIQUE (Phone)
);

-- Table to store order information with status tracking
CREATE TABLE `Order` (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    PaymentStatus ENUM('Pending', 'Paid', 'Refunded', 'Failed') DEFAULT 'Pending',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT chk_total_amount CHECK (TotalAmount >= 0)
);

-- Table to store supplier information
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    ContactInfo VARCHAR(500) NOT NULL,
    Status ENUM('Active', 'Inactive') DEFAULT 'Active',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table to store product information with stock management
CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockLevel INT NOT NULL DEFAULT 0,
    Status ENUM('Active', 'Inactive', 'OutOfStock', 'Discontinued') DEFAULT 'Active',
    SupplierID INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    CONSTRAINT chk_price CHECK (Price >= 0),
    CONSTRAINT chk_stock CHECK (StockLevel >= 0)
);

-- Table to store order details with quantity validation
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Subtotal DECIMAL(10, 2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT chk_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_subtotal CHECK (Subtotal >= 0)
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
    
    -- Update product status if stock becomes 0
    UPDATE Product 
    SET Status = CASE 
        WHEN StockLevel = 0 THEN 'OutOfStock'
        ELSE Status 
    END
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

-- Indexes for better query performance
CREATE INDEX idx_product_category ON Product(Category);
CREATE INDEX idx_product_status ON Product(Status);
CREATE INDEX idx_order_date ON `Order`(OrderDate);
CREATE INDEX idx_order_status ON `Order`(Status);
CREATE INDEX idx_customer_email ON Customer(Email);