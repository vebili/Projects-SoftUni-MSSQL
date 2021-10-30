--CREATE DATABASE Supermarket
--USE Supermarket
--1
CREATE TABLE Categories
(Id     INT
 PRIMARY KEY IDENTITY, 
 [Name] NVARCHAR(30) NOT NULL
);

CREATE TABLE Items
(Id         INT
 PRIMARY KEY IDENTITY, 
 [Name]     NVARCHAR(30) NOT NULL, 
 Price      DECIMAL(15, 2) NOT NULL, 
 CategoryId INT NOT NULL
                FOREIGN KEY REFERENCES Categories(Id)
);

CREATE TABLE Employees
(Id        INT
 PRIMARY KEY IDENTITY, 
 FirstName NVARCHAR(50) NOT NULL, 
 LastName  NVARCHAR(50) NOT NULL, 
 Phone     CHAR(12) NOT NULL, 
 Salary    DECIMAL(15, 2) NOT NULL
);

CREATE TABLE Orders
(Id         INT
 PRIMARY KEY IDENTITY, 
 [DateTime] DATETIME NOT NULL, 
 EmployeeId INT NOT NULL
                FOREIGN KEY REFERENCES Employees(Id)
);

CREATE TABLE OrderItems
(OrderId  INT NOT NULL
              FOREIGN KEY REFERENCES Orders(Id), 
 ItemId   INT NOT NULL
              FOREIGN KEY REFERENCES Items(Id), 
 Quantity INT NOT NULL
              CHECK(Quantity >= 1), 
 PRIMARY KEY(OrderId, ItemId)
);

CREATE TABLE Shifts
(Id         INT IDENTITY, 
 EmployeeId INT NOT NULL
                FOREIGN KEY REFERENCES Employees(Id), 
 CheckIn    DATETIME NOT NULL, 
 CheckOut   DATETIME NOT NULL,
 PRIMARY KEY (Id, EmployeeId),
 CONSTRAINT chk_CheckOut
 CHECK(CheckOut > CheckIn)                      
);
GO

--2
INSERT INTO dbo.Employees
				(FirstName, LastName, Phone, Salary)
VALUES
				(N'Stoyan', N'Petrov', '888-785-8573', 500.25),
				(N'Stamat', N'Nikolov', '789-613-1122', 999995.25),
				(N'Evgeni', N'Petkov', '645-369-9517', 1234.51),
				(N'Krasimir', N'Vidolov', '321-471-9982', 50.25)

INSERT INTO dbo.Items
				([Name], Price, CategoryId)
VALUES
				(N'Tesla battery', 154.25, 8),
				(N'Chess', 30.25, 8),
				(N'Juice', 5.32, 1),
				(N'Glasses', 10, 8),
				(N'Bottle of water', 1, 1)
GO

--3
UPDATE dbo.Items
SET
    dbo.Items.Price *= 1.27
WHERE dbo.Items.CategoryId IN (1, 2, 3)
GO

--4
DELETE FROM dbo.OrderItems
WHERE dbo.OrderItems.OrderId = 48

DELETE FROM dbo.Orders
WHERE dbo.Orders.Id = 48
GO

--5
SELECT e.Id, 
       e.FirstName
FROM dbo.Employees e
WHERE e.Salary > 6500
ORDER BY e.FirstName, 
         e.Id;
GO

--6
SELECT CONCAT(e.FirstName, ' ', e.LastName) [Full Name], 
       e.Phone
FROM dbo.Employees e
WHERE e.Phone LIKE '3%'
ORDER BY e.FirstName, 
         e.Phone;
GO

--7
SELECT e.FirstName, 
       e.LastName, 
       COUNT(o.Id) [Count]
FROM dbo.Employees e
     JOIN dbo.Orders o ON e.Id = o.EmployeeId
GROUP BY e.FirstName, 
         e.LastName
ORDER BY [Count] DESC, 
         e.FirstName;
GO

--8
WITH CTE_WorkDay
     AS (SELECT e.FirstName FirstName, 
                e.LastName LastName, 
                e.Id Id, 
                DATEDIFF(hour, s.CheckIn, s.CheckOut) WorkHours
         FROM dbo.Employees e
              JOIN dbo.Shifts s ON e.Id = s.EmployeeId
         GROUP BY e.FirstName, 
                  e.LastName, 
                  e.Id, 
                  s.CheckIn, 
                  s.CheckOut)

SELECT FirstName, 
       LastName, 
       AVG(WorkHours) [Work hours]
FROM CTE_WorkDay
GROUP BY FirstName, 
         LastName, 
         CTE_WorkDay.Id
HAVING AVG(WorkHours) > 7
ORDER BY [Work hours] DESC, 
         CTE_WorkDay.Id;
GO

--9
SELECT TOP (1) oi.OrderId, 
               SUM(oi.Quantity * i.Price) AS TotalPrice
FROM dbo.Orders o
     JOIN dbo.OrderItems oi ON o.Id = oi.OrderId
     JOIN dbo.Items i ON oi.ItemId = i.Id
GROUP BY oi.OrderId
ORDER BY TotalPrice DESC;
GO

--10
SELECT TOP (10) oi.OrderId, 
                MAX(i.Price) ExpensivePrice, 
                MIN(i.Price) CheapPrice
FROM dbo.Orders o
     JOIN dbo.OrderItems oi ON o.Id = oi.OrderId
     JOIN dbo.Items i ON oi.ItemId = i.Id
GROUP BY oi.OrderId
ORDER BY ExpensivePrice DESC, 
         oi.OrderId;
GO

--11 I example
SELECT e.Id, 
       e.FirstName, 
       e.LastName
FROM dbo.Employees e
     LEFT JOIN dbo.Orders o ON e.Id = o.EmployeeId
WHERE o.Id IS NOT NULL
GROUP BY e.Id, 
         e.FirstName, 
         e.LastName
ORDER BY e.Id;
GO

-- 11 II example
SELECT DISTINCT
  e.Id,
  e.FirstName,
  e.LastName
FROM Employees AS e
  RIGHT JOIN Orders AS o ON o.EmployeeId = e.Id
ORDER BY e.Id

--12
SELECT DISTINCT 
       e.Id, 
       CONCAT(e.FirstName, ' ', e.LastName) [Full Name]
FROM Employees AS e
     JOIN Shifts AS s ON s.EmployeeId = e.Id
WHERE DATEDIFF(HOUR, s.CheckIn, s.CheckOut) < 4
ORDER BY e.Id;
GO

--13
SELECT TOP (10) CONCAT(e.FirstName, ' ', e.LastName) [Full Name], 
                SUM(oi.Quantity * i.Price) AS [Total Price], 
                SUM(oi.Quantity) Items
FROM dbo.Employees e
     JOIN dbo.Orders o ON e.Id = o.EmployeeId
     JOIN dbo.OrderItems oi ON o.Id = oi.OrderId
     JOIN dbo.Items i ON oi.ItemId = i.Id
WHERE o.[DateTime] < '2018-06-15'
GROUP BY e.FirstName, 
         e.LastName
ORDER BY [Total Price] DESC, 
         Items DESC;
GO

--14
SELECT CONCAT(e.FirstName, ' ', e.LastName) [Full Name], 
       DATENAME(weekday, s.CheckIn) [Day of week]
FROM dbo.Employees e
     JOIN dbo.Shifts s ON e.Id = s.EmployeeId
     LEFT JOIN dbo.Orders o ON e.Id = o.EmployeeId
WHERE o.Id IS NULL
      AND DATEDIFF(HOUR, s.CheckIn, s.CheckOut) > 12
ORDER BY e.Id;
GO

--15 
WITH CTE_OrdersSum
     AS (SELECT o.EmployeeId EmployeeId, 
                o.[DateTime] [Date], 
                SUM(oi.Quantity * i.Price) AS TotalPrice, 
                DENSE_RANK() OVER(PARTITION BY o.EmployeeId
								  ORDER BY o.EmployeeId, 
											SUM(oi.Quantity * i.Price) DESC)							AS OrdersRank
         FROM dbo.Orders o
              JOIN dbo.OrderItems oi ON o.Id = oi.OrderId
              JOIN dbo.Items i ON oi.ItemId = i.Id
         GROUP BY o.EmployeeId, 
                  oi.OrderId, 
                  o.[DateTime])     
	 
SELECT CONCAT(e.FirstName, ' ', e.LastName) [Full Name], 
       DATEDIFF(HOUR, s.CheckIn, s.CheckOut) WorkHours, 
       cos.TotalPrice TotalPrice
FROM CTE_OrdersSum cos
     JOIN dbo.Employees e ON cos.EmployeeId = e.Id
     JOIN dbo.Shifts s ON e.Id = s.EmployeeId
WHERE cos.OrdersRank = 1
      AND cos.[Date] BETWEEN s.CheckIn AND s.CheckOut
ORDER BY [Full Name], 
         WorkHours DESC, 
         TotalPrice DESC;
GO

--16
SELECT DATEPART(day, o.[DateTime]) [Day], 
       CAST(AVG(oi.Quantity * i.Price) AS DECIMAL(15, 2)) [Total profit]
FROM dbo.Orders o
     JOIN dbo.OrderItems oi ON o.Id = oi.OrderId
     JOIN dbo.Items i ON oi.ItemId = i.Id
GROUP BY DATEPART(day, o.[DateTime])
ORDER BY [Day];
GO

--17
SELECT i.[Name] Item, 
       c.[Name] Category, 
       SUM(oi.Quantity) [Count], 
       SUM(oi.Quantity) * i.Price TotalPrice
FROM dbo.Items i
     JOIN dbo.Categories c ON i.CategoryId = c.Id
     LEFT JOIN dbo.OrderItems oi ON i.Id = oi.ItemId
GROUP BY i.[Name], 
         c.[Name], 
         i.Price
ORDER BY TotalPrice DESC, 
         [Count] DESC;
GO

--18
CREATE FUNCTION udf_GetPromotedProducts
(@CurrentDate  DATETIME2, 
 @StartDate    DATETIME2, 
 @EndDate      DATETIME2, 
 @Discount     DECIMAL(6, 2), 
 @FirstItemId  INT, 
 @SecondItemId INT, 
 @ThirdItemId  INT
)
RETURNS VARCHAR(100)
AS
     BEGIN
         DECLARE @firstItemName VARCHAR(30)=
         (
             SELECT i.Name
             FROM dbo.Items i
             WHERE i.Id = @FirstItemId
         );
         DECLARE @secondItemName VARCHAR(30)=
         (
             SELECT i.Name
             FROM dbo.Items i
             WHERE i.Id = @SecondItemId
         );
         DECLARE @thirdItemName VARCHAR(30)=
         (
             SELECT i.Name
             FROM dbo.Items i
             WHERE i.Id = @ThirdItemId
         );

         IF(@firstItemName IS NULL
            OR @secondItemName IS NULL
            OR @thirdItemName IS NULL)
             BEGIN
                 RETURN 'One of the items does not exists!';
         END;

         IF(@CurrentDate < @StartDate
            OR @CurrentDate > @EndDate)
             BEGIN
                 RETURN 'The current date is not within the promotion dates!';
         END;

         DECLARE @firstItemPrice DECIMAL(15, 2)=
         (
             SELECT i.Price * (100 - @Discount) / 100
             FROM dbo.Items i
             WHERE i.Id = @FirstItemId
         );
         DECLARE @secondItemPrice DECIMAL(15, 2)=
         (
             SELECT i.Price * (100 - @Discount) / 100
             FROM dbo.Items i
             WHERE i.Id = @SecondItemId
         );
         DECLARE @thirdItemPrice DECIMAL(15, 2)=
         (
             SELECT i.Price * (100 - @Discount) / 100
             FROM dbo.Items i
             WHERE i.Id = @ThirdItemId
         );

         RETURN CONCAT(@firstItemName, ' price: ', @firstItemPrice, ' <-> ', @secondItemName, ' price: ', @secondItemPrice, ' <-> ', @thirdItemName, ' price: ', @thirdItemPrice);
     END;

GO

SELECT dbo.udf_GetPromotedProducts('2018-08-02', '2018-08-01', '2018-08-03',13, 3,4,5)
SELECT dbo.udf_GetPromotedProducts('2018-08-01', '2018-08-02', '2018-08-03',13,3 ,4,5)
SELECT dbo.udf_GetPromotedProducts('2018-08-02', '2018-08-01', '2018-08-03', 13, 3, 4, 165)
GO

--19
CREATE PROC usp_CancelOrder
(@OrderId    INT, 
 @CancelDate DATETIME
)
AS
     DECLARE @orderDate DATETIME=
     (
         SELECT o.[DateTime]
         FROM dbo.Orders o
         WHERE o.Id = @OrderId
     );
     IF(@orderDate IS NULL)
         BEGIN
             RAISERROR('The order does not exist!', 16, 1);
             RETURN;
     END;
     IF(DATEDIFF(day, @orderDate, @CancelDate) >= 3)
         BEGIN
             RAISERROR('You cannot cancel the order!', 16, 2);
             RETURN;
     END;
     DELETE FROM dbo.OrderItems
     WHERE dbo.OrderItems.OrderId = @OrderId;
     DELETE FROM dbo.Orders
     WHERE dbo.Orders.Id = @OrderId;
GO

EXEC usp_CancelOrder 1, '2018-06-02'
SELECT COUNT(*) FROM Orders
SELECT COUNT(*) FROM OrderItems

EXEC usp_CancelOrder 1, '2018-06-15'

EXEC usp_CancelOrder 124231, '2018-06-15'
GO

--20
CREATE TABLE DeletedOrders
(OrderId      INT, 
 ItemId       INT, 
 ItemQuantity INT
);
GO

CREATE TRIGGER tr_OrderDeleted ON dbo.OrderItems
FOR DELETE
AS
     INSERT INTO dbo.DeletedOrders
     (OrderId, 
      ItemId, 
      ItemQuantity
     )
            SELECT *
            FROM DELETED d;

GO