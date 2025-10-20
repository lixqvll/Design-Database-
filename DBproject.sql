CREATE SCHEMA IF NOT EXISTS ShoppingCartDB;
USE ShoppingCartDB;

CREATE TABLE IF NOT EXISTS Customer(
CustomerID INT NOT NULL UNIQUE,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
PhoneNumber VARCHAR(12) UNIQUE NOT NULL,
Email VARCHAR(100) UNIQUE NOT NULL,
CONSTRAINT Customer_PK PRIMARY KEY(CustomerID)
);

CREATE TABLE IF NOT EXISTS Product(
ProductID INT NOT NULL UNIQUE,
NameOfProuct VARCHAR(100) NOT NULL,
PriceOfProdect DECIMAL(10,2) NOT NULL,
StockQuantiy INT NOT NULL,
ProductStatus VARCHAR(20) CHECK (ProductStatus IN('Available','unavailable','Almost done')),
CONSTRAINT Product_PK PRIMARY KEY (ProductID)
);

CREATE TABLE IF NOT EXISTS Cart(
CartID INT NOT NULL UNIQUE,
CreatedDate DATE,
CONSTRAINT Cart_PK PRIMARY KEY (CartID)
);

CREATE TABLE IF NOT EXISTS CartProduct (
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    PRIMARY KEY (CartID, ProductID),
    FOREIGN KEY (CartID) REFERENCES Cart(CartID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Payment(
PaymentID INT NOT NULL UNIQUE,
PaymentMethod VARCHAR(20) CHECK(PaymentMethod IN ('upon receipt', 'credit card', 'Apple Pay')),
AmountPaid DECIMAL(10, 2) NOT NULL,
PaymentDate DATE,
paymentStatus VARCHAR(20) CHECK (paymentStatus IN ('Paid', 'Canceled', 'Awaiting Payment')),
CONSTRAINT Payment_PK PRIMARY KEY (PaymentID)
);

CREATE TABLE IF NOT EXISTS Orders(
OrderID INT NOT NULL UNIQUE,
OrderDate DATE,
OrderStatus VARCHAR(20) CHECK (OrderStatus IN ('Being Prepared', 'Shipped', 'Delivered', 'Canceled', 'Awaiting Payment')),
CustomerID INT NOT NULL,
CartID INT NOT NULL UNIQUE,
PaymentID INT NOT NULL UNIQUE,
CONSTRAINT Order_PK PRIMARY KEY (OrderID),
CONSTRAINT Order_FK1 FOREIGN KEY (CartID) REFERENCES Cart(CartID) ON DELETE CASCADE,
CONSTRAINT Order_FK2 FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
CONSTRAINT Order_FK3 FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID) ON DELETE CASCADE
); 

INSERT INTO Customer (CustomerID, FirstName, LastName, PhoneNumber, Email)
VALUES  
(1111, 'Hassan', 'Alamri', '0561234567', 'Hassan@gmail.com'),  
(1112, 'Aisha', 'Almutairi', '0544875620', 'Aisha@gmail.com'),  
(1113, 'Lama', 'Alshammari', '0561478554', 'Lama@gmail.com'),  
(1114, 'Fahad', 'Alqahtani', '0571477851', 'Fahad@gmail.com'),  
(1115, 'Salem', 'Alharbi', '0562547813', 'Salem@gmail.com'); 

INSERT INTO Product (ProductID, NameOfProuct, PriceOfProdect, StockQuantiy, ProductStatus)
VALUES
(1, 'Laptop', 1200.99, 10, 'Almost done'),
(2, 'Smartphone', 699.49, 62, 'Available'),
(3, 'Desk', 150.00, 112, 'Available'),
(4, 'Chair', 85.99, 0, 'unavailable'),
(5, 'Book', 12.49, 84, 'Available');

INSERT INTO Cart (CartID, CreatedDate)
VALUES  
(101, '2022-12-1'),  
(102, '2023-1-3'),  
(103, '2024-3-4'),  
(104, '2024-6-4'),  
(105, '2025-1-12'); 

INSERT INTO CartProduct (CartID, ProductID)
VALUES  
(101, 1),  
(102, 2),  
(103, 3),  
(104, 4),  
(105, 5); 

INSERT INTO Payment (PaymentID, PaymentMethod, AmountPaid, PaymentDate, PaymentStatus)
VALUES
(221001, 'upon receipt', 1200.99, '2025-1-7', 'Paid'),
(221002, 'Apple Pay', 699.49, '2025-1-1', 'Canceled'),
(221003, 'credit card', 150.00, '2025-1-1', 'Paid'),
(221004, 'upon receipt', 85.99, '2025-1-1', 'Paid'),
(221005, 'Apple Pay', 12.49, '2025-1-1', 'Paid');

INSERT INTO Orders (OrderID, OrderDate, OrderStatus, CustomerID, CartID, PaymentID)  
VALUES 
(104454, '2024-12-30', 'Delivered', 1111, 101, 221001),  
(104453, '2025-1-1', 'Canceled', 1112, 102, 221002),  
(104451, '2025-1-1', 'Shipped', 1113, 103, 221003),  
(104455, '2025-1-7', 'Delivered', 1114, 104, 221004), 
(104452, '2025-1-14', 'Being Prepared', 1115, 105, 221005);  

UPDATE Payment
SET PaymentMethod = 'credit card'
WHERE PaymentID = 5;

DELETE FROM orders
WHERE OrderID = 104455;

SELECT *
FROM Product
WHERE PriceOfProdect > 75;

SELECT PaymentMethod, SUM(AmountPaid) AS Total
FROM Payment
GROUP BY PaymentMethod;

SELECT PaymentMethod, SUM(AmountPaid) AS TotalAmount
FROM Payment
GROUP BY PaymentMethod
HAVING SUM(AmountPaid) > 300;

SELECT *
FROM Orders
ORDER BY OrderID;

SELECT NameOfProuct
FROM Product 
WHERE ProductID IN (
    SELECT ProductID 
    FROM Cart 
    WHERE CartID IN (
        SELECT CartID 
        FROM Orders 
        WHERE OrderStatus = 'Delivered' OR OrderStatus = 'Being Prepared' OR OrderStatus = 'Shipped'
    )
);

SELECT 
    o.OrderID, 
    o.OrderDate, 
    o.OrderStatus, 
    c.FirstName, 
    c.LastName, 
    p.PaymentMethod, 
    p.AmountPaid
FROM Orders o
JOIN Customer c ON o.CustomerID = c.CustomerID
JOIN Payment p ON o.PaymentID = p.PaymentID;