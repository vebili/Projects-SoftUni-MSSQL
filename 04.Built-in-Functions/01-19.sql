USE SoftUni;
--1
SELECT FirstName, 
       LastName
FROM Employees
WHERE dbo.Employees.FirstName LIKE 'SA%' 

GO


USE SoftUni;
--2
SELECT FirstName, 
       LastName
FROM Employees
WHERE dbo.Employees.LastName LIKE '%ei%' 

GO


USE SoftUni;
--3
SELECT FirstName
FROM Employees
WHERE dbo.Employees.DepartmentID IN(3, 10)
AND DATEPART(year, HireDate) BETWEEN 1995 AND 2005;

GO


USE SoftUni;
--4
SELECT FirstName, 
       LastName
FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

GO


USE SoftUni;
--5
SELECT [Name]
FROM Towns
WHERE len([Name]) BETWEEN 5 AND 6
ORDER BY [Name]

GO


USE SoftUni;
--6
SELECT TownId, 
       [Name]
FROM Towns
WHERE LEFT([Name], 1) IN('M', 'K', 'B', 'E')
ORDER BY [Name];

GO

USE SoftUni;
--6
SELECT TownId, 
       [Name]
FROM Towns
WHERE LEFT([Name], 1) LIKE ('[MKBE]%')
ORDER BY [Name];

GO


USE SoftUni;
--7
SELECT TownId, 
       [Name]
FROM Towns
WHERE LEFT([Name], 1) NOT IN('R', 'D', 'B')
ORDER BY [Name];

GO


USE SoftUni;
--8
GO
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, 
       LastName
FROM Employees
WHERE DATEPART(year, HireDate) > 2000

GO


USE SoftUni;
--9
SELECT FirstName, 
       LastName
FROM Employees
WHERE len(LastName) = 5

GO


USE SoftUni;
--10
SELECT EmployeeID, 
       FirstName, 
       LastName, 
       Salary, 
       DENSE_RANK() OVER(PARTITION BY Salary
       ORDER BY EmployeeID) AS Rank
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC;

GO


USE SoftUni;
--11
SELECT *
FROM
(
    SELECT EmployeeID, 
           FirstName, 
           LastName, 
           Salary, 
           DENSE_RANK() OVER(PARTITION BY Salary
           ORDER BY EmployeeID) AS [Rank]
    FROM Employees
    WHERE Salary BETWEEN 10000 AND 50000
) AS tablWithRanks
WHERE tablWithRanks.[Rank] = 2
ORDER BY Salary DESC;

GO



USE [Geography]
--12
SELECT CountryName, IsoCode 
FROM Countries
WHERE CountryName LIKE '%A%A%A%'
ORDER BY IsoCode

GO


USE [Geography]
--13
SELECT p.PeakName, 
       r.RiverName, 
       LOWER(concat(LEFT(p.PeakName, LEN(p.PeakName) - 1), r.RiverName)) AS [Mix]
FROM Peaks AS p
     INNER JOIN Rivers AS r ON RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY [Mix];

GO

USE [Geography]
--13
SELECT p.PeakName, 
       r.RiverName, 
       LOWER(concat(LEFT(p.PeakName, LEN(p.PeakName) - 1), r.RiverName)) AS [Mix]
FROM Peaks AS p, 
     Rivers AS r
WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY [Mix];

GO


USE Diablo
--14
SELECT TOP (50) [Name], 
                FORMAT([Start], 'yyyy-MM-dd') AS [Start]
FROM Games
WHERE DATEPART(YEAR, [Start]) IN(2011, 2012)
ORDER BY [Start], 
         [Name];
GO


USE Diablo
--15
SELECT Username, 
       SUBSTRING(
				Email, 
				CHARINDEX('@', Email) + 1, 
				(LEN(Email) - CHARINDEX('@', Email))) 
		AS [Email Provider]
FROM Users
ORDER BY [Email Provider], 
         Username;
GO



USE Diablo
--17
SELECT g.[Name] AS [Game],
		CASE 
			WHEN datepart(hour ,g.[Start]) BETWEEN 0 AND 11 THEN 'Morning'
			WHEN datepart(hour ,g.[Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS [Part of the Day],
		CASE 
			WHEN g.Duration <= 3 THEN 'Extra Short'
			WHEN g.Duration BETWEEN 4 AND 6 THEN 'Short'
			WHEN g.Duration > 6 THEN 'Long'
			WHEN g.Duration IS null THEN 'Extra Long'			
		END AS [Duration]
FROM Games as g
ORDER BY [Game], [Duration], [Part of the Day]

GO


USE Orders
--18
SELECT ProductName,
		OrderDate,
		dateadd(day, 3, OrderDate) AS [Pay Due],
		dateadd(month, 1, OrderDate) AS [Deliver Due]
FROM Orders

GO


USE Orders
--19
CREATE TABLE People
(	Id        INT
				PRIMARY KEY IDENTITY, 
	[Name]    NVARCHAR(50) NOT NULL, 
	BirthDate DATETIME2
);

INSERT INTO dbo.People
				([Name], BirthDate)
VALUES
				('Victor', '2000-12-07'),
				('Steven', '1992-09-10'),
				('Stephen', '1910-09-19'),
				('John', '2010-01-06')


SELECT [Name], 
       DATEDIFF(year, BirthDate, GETDATE()) AS [Age in Years], 
       DATEDIFF(month, BirthDate, GETDATE()) AS [Age in Months], 
       DATEDIFF(day, BirthDate, GETDATE()) AS [Age in Days], 
       DATEDIFF(minute, BirthDate, GETDATE()) AS [Age in Minutes]
FROM People;
