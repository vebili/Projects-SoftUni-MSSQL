--CREATE DATABASE TripService
--USE TripService
--1
CREATE TABLE Cities
(Id          INT
 PRIMARY KEY IDENTITY, 
 [Name]      NVARCHAR(20) NOT NULL, 
 CountryCode CHAR(2) NOT NULL
);

CREATE TABLE Hotels
(Id            INT
 PRIMARY KEY IDENTITY, 
 [Name]        NVARCHAR(30) NOT NULL, 
 CityId        INT NOT NULL FOREIGN KEY REFERENCES Cities(Id), 
 EmployeeCount INT NOT NULL, 
 BaseRate      DECIMAL(15, 2)
);

CREATE TABLE Rooms
(Id      INT PRIMARY KEY IDENTITY, 
 Price   DECIMAL(15, 2) NOT NULL, 
 [Type]  NVARCHAR(20) NOT NULL, 
 Beds    INT NOT NULL, 
 HotelId INT NOT NULL FOREIGN KEY REFERENCES Hotels(Id)
);

CREATE TABLE Trips
(Id          INT PRIMARY KEY IDENTITY, 
 RoomId      INT NOT NULL FOREIGN KEY REFERENCES Rooms(Id), 
 BookDate    DATETIME2 NOT NULL, 
 ArrivalDate DATETIME2 NOT NULL, 
 ReturnDate  DATETIME2 NOT NULL, 
 CancelDate  DATETIME2, 
 CONSTRAINT chk_BookDate CHECK(BookDate < ArrivalDate), 
 CONSTRAINT chk_ArrivalDate CHECK(ArrivalDate < ReturnDate)
);

CREATE TABLE Accounts
(Id         INT PRIMARY KEY IDENTITY, 
 FirstName  NVARCHAR(50) NOT NULL, 
 MiddleName NVARCHAR(20), 
 LastName   NVARCHAR(50) NOT NULL, 
 CityId     INT NOT NULL FOREIGN KEY REFERENCES Cities(Id), 
 BirthDate  DATETIME2 NOT NULL, 
 Email      NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE AccountsTrips
(AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id), 
 TripId    INT NOT NULL FOREIGN KEY REFERENCES Trips(Id), 
 Luggage   INT NOT NULL CHECK(Luggage >= 0),
PRIMARY KEY (AccountId, TripId)
);
GO

--2
INSERT INTO dbo.Accounts
	(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
VALUES
	(N'John', N'Smith', N'Smith', 34, '1975-07-21', N'j_smith@gmail.com' ),
	(N'Gosho', NULL, N'Petrov', 11, '1978-05-16', N'g_petrov@gmail.com' ),
	(N'Ivan', N'Petrovich', N'Pavlov', 59, '1849-09-26', N'i_pavlov@softuni.bg' ),
	(N'Friedrich', N'Wilhelm', N'Nietzsche', 2, '1844-10-15', N'f_nietzsche@softuni.bg' )

INSERT INTO dbo.Trips
	(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
VALUES
	(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
	(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
	(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
	(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
	(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)
GO

--3
UPDATE dbo.Rooms
  SET 
      dbo.Rooms.Price*=1.14
WHERE dbo.Rooms.HotelId IN(5, 7, 9);
GO

--4
DELETE FROM dbo.AccountsTrips
WHERE dbo.AccountsTrips.AccountId = 47
GO

--5
SELECT c.Id, 
       c.Name
FROM dbo.Cities c
WHERE c.CountryCode = 'BG'
ORDER BY c.Name;
GO

--6
SELECT CONCAT(a.FirstName, ' ', a.MiddleName + ' ', a.LastName) [Full Name], 
       DATEPART(year, a.BirthDate) BirthYear
FROM dbo.Accounts a
WHERE DATEPART(year, a.BirthDate) > '1991'
ORDER BY BirthYear DESC, 
         a.FirstName;
GO

--7
SELECT a.FirstName, 
       a.LastName, 
       format(a.BirthDate, 'MM-dd-yyyy') BirthDate, 
       c.Name Hometown, 
       a.Email
FROM dbo.Accounts a
     JOIN dbo.Cities c ON a.CityId = c.Id
WHERE a.Email LIKE 'e%'
ORDER BY c.Name DESC;
GO

--8
SELECT c.Name City, 
       COUNT(h.Id) Hotels
FROM dbo.Cities c
     LEFT JOIN dbo.Hotels h ON c.Id = h.CityId
GROUP BY c.Name
ORDER BY Hotels DESC, 
         City;
GO

--9
SELECT r.Id, 
       r.Price, 
       h.Name Hotel, 
       c.Name City
FROM dbo.Rooms r
     JOIN dbo.Hotels h ON r.HotelId = h.Id
     JOIN dbo.Cities c ON h.CityId = c.Id
WHERE r.Type = 'First Class'
ORDER BY r.Price DESC, 
         r.Id;
GO

--10
WITH CTE_TripDays AS (SELECT a.Id AccountId, 
       CONCAT(a.FirstName, ' ', a.LastName) FullName,
	   DATEDIFF(day, t.ArrivalDate, t.ReturnDate) Trip
FROM dbo.Accounts a
     JOIN dbo.AccountsTrips act ON a.Id = act.AccountId
     JOIN dbo.Trips t ON act.TripId = t.Id
WHERE a.MiddleName IS NULL
      AND t.CancelDate IS NULL
GROUP BY a.Id, 
         a.FirstName, 
         a.LastName, 
         t.ArrivalDate, 
         t.ReturnDate)

SELECT AccountId, 
       FullName, 
       MAX(Trip) LongestTrip, 
       MIN(Trip) ShortestTrip
FROM CTE_TripDays ctd
GROUP BY AccountId, 
         FullName
ORDER BY LongestTrip DESC, 
         ctd.AccountId;
GO

--11
SELECT TOP (5) c.Id, 
               c.Name City, 
               c.CountryCode, 
               COUNT(a.Id) Accounts
FROM dbo.Cities c
     LEFT JOIN dbo.Accounts a ON a.CityId = c.Id
GROUP BY c.Id, 
         c.Name, 
         c.CountryCode
ORDER BY Accounts DESC;
GO

--12
SELECT a.Id, 
       a.Email, 
       c.Name City, 
       COUNT(t.Id) Trips
FROM dbo.Accounts a
     JOIN dbo.Cities c ON a.CityId = c.Id
     JOIN dbo.AccountsTrips act ON a.Id = act.AccountId
     JOIN dbo.Trips t ON act.TripId = t.Id
     JOIN dbo.Rooms r ON t.RoomId = r.Id
     JOIN dbo.Hotels h ON r.HotelId = h.Id
WHERE a.CityId = h.CityId
GROUP BY a.Id, 
         a.Email, 
         c.Name
ORDER BY Trips DESC, 
         a.Id;
GO

--13
SELECT TOP (10) c.Id, 
                c.Name, 
                SUM(h.BaseRate + r.Price) [Total Revenue], 
                COUNT(t.Id) Trips
FROM dbo.Cities c
     JOIN dbo.Hotels h ON c.Id = h.CityId
     JOIN dbo.Rooms r ON r.HotelId = h.Id
     JOIN dbo.Trips t ON t.RoomId = r.Id
WHERE DATEPART(YEAR, t.BookDate) = '2016'
GROUP BY c.Id, 
         c.Name
ORDER BY [Total Revenue] DESC, 
         Trips DESC;
GO

--14 Made trips -> the trip must be connected with account
SELECT t.Id, 
       h.Name HotelName, 
       r.Type RoomType, 
       IIF(t.CancelDate IS NOT NULL, 0, SUM(h.BaseRate + r.Price)) Revenue
FROM dbo.Trips t
     JOIN dbo.Rooms r ON r.Id = t.RoomId
     JOIN dbo.Hotels h ON h.Id = r.HotelId
	 JOIN dbo.AccountsTrips act ON act.TripId = t.Id
GROUP BY t.Id, 
         h.Name, 
         r.Type,
		 t.CancelDate
ORDER BY RoomType, 
         t.Id;
GO

--15
WITH CTE_CityRank AS (SELECT a.Id AccountId, 
       a.Email, 
       c.CountryCode, 
       COUNT(t.Id) Trips, 
       DENSE_RANK() OVER(PARTITION BY c.CountryCode
       ORDER BY COUNT(t.Id) DESC, 
                a.Id) cityRank
FROM dbo.Accounts a
     JOIN dbo.AccountsTrips act ON act.AccountId = a.Id
     JOIN dbo.Trips t ON act.TripId = t.Id
     JOIN dbo.Rooms r ON t.RoomId = r.Id
     JOIN dbo.Hotels h ON r.HotelId = h.Id
     JOIN dbo.Cities c ON h.CityId = c.Id
GROUP BY c.CountryCode, 
         a.Email, 
         a.Id)

SELECT ccr.AccountId, 
       ccr.Email, 
       ccr.CountryCode, 
       ccr.Trips
FROM CTE_CityRank ccr
WHERE ccr.cityRank = 1
ORDER BY ccr.Trips DESC, 
         ccr.AccountId;
GO

--16 action if a trip has more than 5 items of luggage 
SELECT t.Id, 
       SUM(act.Luggage) Luggage, 
       CONCAT('$', IIF(SUM(act.Luggage) > 5, SUM(act.Luggage) * 5, 0)) Fee
FROM dbo.Trips t
     JOIN dbo.AccountsTrips act ON act.TripId = t.Id
GROUP BY t.Id
HAVING SUM(act.Luggage) > 0
ORDER BY Luggage DESC;
GO

--17
SELECT t.Id, 
       CONCAT(a.FirstName, ' ', a.MiddleName + ' ', a.LastName) [Full Name],
       cFrom.Name [From], 
       cTo.Name [To], 
       IIF(t.CancelDate IS NOT NULL, 'Canceled', CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')) Duration
FROM dbo.Accounts a
     JOIN dbo.Cities cFrom ON a.CityId = cFrom.Id
     JOIN dbo.AccountsTrips act ON act.AccountId = a.Id
     JOIN dbo.Trips t ON act.TripId = t.Id
     JOIN dbo.Rooms r ON t.RoomId = r.Id
     JOIN dbo.Hotels h ON r.HotelId = h.Id
     JOIN dbo.Cities cTo ON h.CityId = cTo.Id
ORDER BY [Full Name], 
         t.Id;
GO

--18
CREATE FUNCTION udf_GetAvailableRoom
(@HotelId INT, 
 @Date    DATETIME2, 
 @People  INT
)
RETURNS VARCHAR(MAX)
     BEGIN
         DECLARE @BookedRooms TABLE(Id INT);
         INSERT INTO @BookedRooms
                SELECT DISTINCT 
                       r.Id
                FROM Rooms r
                     LEFT JOIN Trips t ON r.Id = t.RoomId
                WHERE r.HotelId = @HotelId
                      AND @Date BETWEEN t.ArrivalDate AND t.ReturnDate
                      AND t.CancelDate IS NULL;

         DECLARE @Rooms TABLE
         (Id         INT, 
          Price      DECIMAL(15, 2), 
          Type       VARCHAR(20), 
          Beds       INT, 
          TotalPrice DECIMAL(15, 2)
         );
         INSERT INTO @Rooms
                SELECT TOP 1 R.Id, 
                             R.Price, 
                             R.Type, 
                             R.Beds, 
                             @People * (H.BaseRate + R.Price) AS TotalPrice
                FROM Rooms R
                     LEFT JOIN Hotels H ON R.HotelId = H.Id
                WHERE R.HotelId = @HotelId
                      AND R.Beds >= @People
                      AND R.Id NOT IN
                (
                    SELECT Id
                    FROM @BookedRooms
                )
                ORDER BY TotalPrice DESC;

         DECLARE @RoomCount INT=
         (
             SELECT COUNT(*)
             FROM @Rooms
         );

         IF(@RoomCount < 1)
             BEGIN
                 RETURN 'No rooms available';
         END;

         DECLARE @Result VARCHAR(MAX)=
         (
             SELECT CONCAT('Room ', Id, ': ', Type, ' (', Beds, ' beds) - ', '$', TotalPrice)
             FROM @Rooms
         );

         RETURN @Result;
     END;
GO

--19
CREATE PROC usp_SwitchRoom(@TripId int, @TargetRoomId int)
AS

DECLARE @roomHotelId INT=
(
    SELECT r.HotelId
    FROM dbo.Rooms r
    WHERE r.Id = @TargetRoomId
);

DECLARE @tripHotelId INT=
(
    SELECT r.HotelId
    FROM dbo.Trips t
         JOIN dbo.Rooms r ON t.RoomId = r.Id
    WHERE t.Id = @TripId
);

IF(@roomHotelId <> @tripHotelId)
    BEGIN
        RAISERROR('Target room is in another hotel!', 16, 1);
		RETURN
END;

DECLARE @roomBedCount INT=
(
    SELECT r.Beds
    FROM dbo.Rooms r
    WHERE r.Id = @TargetRoomId
);

DECLARE @tripBedCount INT=
(
    SELECT COUNT(act.AccountId)
    FROM dbo.AccountsTrips act
    WHERE act.TripId = @TripId
);

IF(@roomBedCount < @tripBedCount)
    BEGIN
        RAISERROR('Not enough beds in target room!', 16, 2);
		RETURN
END;

UPDATE dbo.Trips
  SET 
      dbo.Trips.RoomId = @TargetRoomId
WHERE dbo.Trips.Id = @TripId;

GO

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10
EXEC usp_SwitchRoom 10, 7
EXEC usp_SwitchRoom 10, 8
GO

--20
CREATE TRIGGER tr_CancelTrip ON dbo.Trips
INSTEAD OF DELETE
AS
     UPDATE dbo.Trips
       SET 
           dbo.Trips.CancelDate = GETDATE()
     WHERE dbo.Trips.Id IN
     (
         SELECT Id
         FROM DELETED
         WHERE DELETED.CancelDate IS NULL
     );