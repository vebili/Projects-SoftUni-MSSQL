CREATE DATABASE Airport
--1
USE Airport
GO

CREATE TABLE Planes
(Id      INT
 PRIMARY KEY IDENTITY, 
 [Name]  VARCHAR(30) NOT NULL, 
 Seats   INT NOT NULL, 
 [Range] INT NOT NULL
);

CREATE TABLE Flights
(Id            INT
 PRIMARY KEY IDENTITY, 
 DepartureTime DATETIME2, 
 ArrivalTime   DATETIME2, 
 [Origin]      VARCHAR(50) NOT NULL, 
 [Destination] VARCHAR(50) NOT NULL, 
 PlaneId       INT NOT NULL
                   FOREIGN KEY REFERENCES Planes(Id)
);

CREATE TABLE Passengers
(Id         INT
 PRIMARY KEY IDENTITY, 
 FirstName  VARCHAR(30) NOT NULL, 
 LastName   VARCHAR(30) NOT NULL, 
 Age        INT NOT NULL, 
 Address    VARCHAR(30) NOT NULL, 
 PassportId CHAR(11) NOT NULL
);

CREATE TABLE LuggageTypes
(Id     INT
 PRIMARY KEY IDENTITY, 
 [Type] VARCHAR(30) NOT NULL
);

CREATE TABLE Luggages
(Id            INT
 PRIMARY KEY IDENTITY, 
 LuggageTypeId INT NOT NULL
                   FOREIGN KEY REFERENCES LuggageTypes(Id), 
 PassengerId   INT NOT NULL
                   FOREIGN KEY REFERENCES Passengers(Id),
);

CREATE TABLE Tickets
(Id            INT
 PRIMARY KEY IDENTITY, 
 PassengerId   INT NOT NULL
                   FOREIGN KEY REFERENCES Passengers(Id), 
 FlightId      INT NOT NULL
                   FOREIGN KEY REFERENCES Flights(Id), 
 LuggageId INT NOT NULL
                   FOREIGN KEY REFERENCES Luggages(Id), 
 Price         DECIMAL(18, 2) NOT NULL
);

GO

--2
USE Airport
GO

INSERT INTO dbo.Planes
			(Name, Seats, Range)
VALUES
			('Airbus 336', 112, 5132),
			('Airbus 330', 432, 5325),
			('Boeing 369', 231, 2355),
			('Stelt 297', 254, 2143),
			('Boeing 338', 165, 5111),
			('Airbus 558', 387, 1342),
			('Boeing 128', 345, 5541);

INSERT INTO dbo.LuggageTypes
VALUES 
		('Crossbody Bag'),
		('School Backpack'),
		('Shoulder Bag');

GO

--3
USE Airport
GO

UPDATE dbo.Tickets
  SET 
      dbo.Tickets.Price*=1.13
WHERE dbo.Tickets.FlightId IN
(
    SELECT f.Id
    FROM dbo.Flights f
    WHERE f.Destination = 'Carlsbad'
);

GO

--4
USE Airport
GO

DECLARE @flightId int = (SELECT f.Id FROM dbo.Flights f WHERE f.Destination = 'Ayn Halagim')

DELETE FROM dbo.Tickets
WHERE dbo.Tickets.FlightId = @flightId

DELETE FROM dbo.Flights
WHERE dbo.Flights.Id = @flightId;

GO


--5
USE Airport
GO

SELECT f.Origin, 
       f.Destination
FROM dbo.Flights f
ORDER BY f.Origin, 
         f.Destination;

GO

--6
USE Airport
GO

SELECT *
FROM dbo.Planes p
WHERE p.Name LIKE '%tr%'
ORDER BY p.Id, 
         p.Name, 
         p.Seats, 
         p.Range;

GO

--7
USE Airport
GO

SELECT f.Id, 
       SUM(t.Price) Price
FROM dbo.Flights f
     JOIN dbo.Tickets t ON f.Id = t.FlightId
GROUP BY f.Id
ORDER BY Price DESC, 
         f.Id;
		 
GO

--8
USE Airport
GO

SELECT TOP (10) p.FirstName, 
                p.LastName, 
                t.Price
FROM dbo.Passengers p
     JOIN dbo.Tickets t ON p.Id = t.PassengerId
ORDER BY t.Price DESC, 
         p.FirstName, 
         p.LastName;

GO

--9
USE Airport
GO

SELECT lt.[Type], 
       COUNT(p.Id) MostUsedLuggage
FROM dbo.Passengers p
     JOIN dbo.Luggages l ON p.Id = l.PassengerId
     JOIN dbo.LuggageTypes lt ON l.LuggageTypeId = lt.Id
GROUP BY lt.[Type]
ORDER BY MostUsedLuggage DESC, 
         lt.[Type];

GO

--10
USE Airport
GO

SELECT CONCAT(p.FirstName, ' ', p.LastName) [Full Name], 
       f.Origin, 
       f.Destination
FROM dbo.Flights f
     JOIN dbo.Tickets t ON f.Id = t.FlightId
     JOIN dbo.Passengers p ON t.PassengerId = p.Id
ORDER BY [Full Name], 
         f.Origin, 
         f.Destination;

GO

--11
USE Airport
GO

SELECT p.FirstName, 
       p.LastName, 
       p.Age
FROM dbo.Passengers p
     LEFT JOIN dbo.Tickets t ON p.Id = t.PassengerId
WHERE t.PassengerId IS NULL
ORDER BY p.Age DESC, 
         p.FirstName, 
         p.LastName;

GO

--12
USE Airport
GO

SELECT p.PassportId [Passport Id], 
       p.[Address]
FROM dbo.Passengers p
     LEFT JOIN dbo.Luggages l ON p.Id = l.PassengerId
WHERE l.Id IS NULL
ORDER BY [Passport Id], 
         p.[Address];

GO

--13
USE Airport
GO

SELECT p.FirstName, 
       p.LastName, 
       COUNT(t.Id) [Total Trips]
FROM dbo.Passengers p
     LEFT JOIN dbo.Tickets t ON p.Id = t.PassengerId
GROUP BY p.Id, 
         p.FirstName, 
         p.LastName
ORDER BY [Total Trips] DESC, 
         p.FirstName, 
         p.LastName;

GO

--14
USE Airport
GO

SELECT CONCAT(p.FirstName, ' ', p.LastName) [Full Name], 
       pl.Name [Plane Name], 
       CONCAT(f.Origin, ' - ', f.Destination) [Trip], 
       lt.Type
FROM dbo.Flights f
     JOIN dbo.Tickets t ON f.Id = t.FlightId
     JOIN dbo.Passengers p ON t.PassengerId = p.Id
     JOIN dbo.Planes pl ON f.PlaneId = pl.Id
     JOIN dbo.Luggages l ON t.LuggageId = l.Id
     JOIN dbo.LuggageTypes lt ON l.LuggageTypeId = lt.Id
WHERE f.Origin IS NOT NULL
      AND f.Destination IS NOT NULL
ORDER BY [Full Name], 
         [Plane Name], 
         f.Origin, 
         f.Destination, 
         lt.Type;

GO

--15
USE Airport
GO

WITH CTE_PiceRanks
     AS (SELECT p.FirstName FirstName, 
                p.LastName LastName, 
                f.Destination Destination, 
                t.Price Price, 
                DENSE_RANK() OVER(PARTITION BY p.Id
                ORDER BY t.Price DESC) RankTicketPrice
         FROM dbo.Passengers p
              JOIN dbo.Tickets t ON p.Id = t.PassengerId
              JOIN dbo.Flights f ON t.FlightId = f.Id)
     SELECT FirstName, 
            LastName, 
            Destination, 
            Price
     FROM CTE_PiceRanks
     WHERE CTE_PiceRanks.RankTicketPrice = 1
     ORDER BY Price DESC, 
              FirstName, 
              LastName, 
              Destination;

GO

--16
USE Airport
GO

SELECT f.Destination, 
       COUNT(t.Id) FilesCount
FROM dbo.Flights f
     LEFT JOIN dbo.Tickets t ON f.Id = t.FlightId
GROUP BY f.Destination
ORDER BY FilesCount DESC, 
         f.Destination;


GO

--17
USE Airport
GO

SELECT p.Name, 
       p.Seats, 
       COUNT(t.PassengerId) [Passengers Count]
FROM dbo.Planes p
     LEFT JOIN dbo.Flights f ON p.Id = f.PlaneId
     LEFT JOIN dbo.Tickets t ON f.Id = t.FlightId
GROUP BY p.Id, 
         p.Name, 
         p.Seats
ORDER BY [Passengers Count] DESC, 
         p.Name, 
         p.Seats;

GO

--18
USE Airport
GO

CREATE FUNCTION udf_CalculateTickets
(@origin      VARCHAR(50), 
 @destination VARCHAR(50), 
 @peopleCount INT
)
RETURNS VARCHAR(50)
AS
     BEGIN
         IF(@peopleCount <= 0)
             BEGIN
                 RETURN 'Invalid people count!';
         END;

         DECLARE @flightId INT=
         (
             SELECT f.Id
             FROM dbo.Flights f
             WHERE f.Origin = @origin
                   AND f.Destination = @destination
         );

         IF(@flightId IS NULL)
             BEGIN
                 RETURN 'Invalid flight!';
         END;

         DECLARE @totalPrice DECIMAL(24, 2)=
         (
             SELECT t.Price * @peopleCount
             FROM dbo.Tickets t
             WHERE t.FlightId = @flightId
         );

         RETURN 'Total price ' + Convert(varchar(50), @totalPrice);
     END;

GO

SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)
SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', -1)
SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)
GO
 
--19
USE Airport
GO

CREATE PROC usp_CancelFlights
AS
     UPDATE dbo.Flights
       SET 
           dbo.Flights.DepartureTime = NULL, 
           dbo.Flights.ArrivalTime = NULL
     WHERE DATEDIFF(second, dbo.Flights.DepartureTime, dbo.Flights.ArrivalTime) > 0;

GO

EXEC usp_CancelFlights
GO

--20
USE Airport
GO

CREATE TABLE DeletedPlanes
(Id    INT, 
 Name  VARCHAR(30), 
 Seats INT, 
 Range INT
);

CREATE TRIGGER tr_DeletedPlanes ON Planes 
AFTER DELETE AS
  INSERT INTO DeletedPlanes (Id, Name, Seats, Range) 
      (SELECT Id, Name, Seats, Range FROM deleted)

GO
