USE SoftUni
--2
SELECT * FROM Departments

GO

USE SoftUni
--3
SELECT [Name] FROM Departments

GO


USE SoftUni
--4
SELECT FirstName, LastName, Salary 
FROM Employees

GO


USE SoftUni
--5
SELECT FirstName, MiddleName, LastName
FROM Employees

GO


USE SoftUni
--6
SELECT FirstName + '.' + LastName + '@softuni.bg' AS 'Full Email Address'
FROM Employees

GO


USE SoftUni
--7
SELECT DISTINCT Salary
FROM Employees

GO

USE SoftUni
--8
SELECT * 
FROM Employees
WHERE JobTitle = 'Sales Representative'

GO


USE SoftUni
--9
SELECT dbo.Employees.FirstName, 
       dbo.Employees.LastName, 
       dbo.Employees.JobTitle
FROM Employees
WHERE Salary BETWEEN 20000 AND 30000;

GO


USE SoftUni
--10
SELECT CONCAT(FirstName, ' ', MiddleName + ' ', LastName) AS [Full Name]
FROM Employees
WHERE Salary IN (25000, 14000, 12500, 23600)

USE SoftUni

SELECT FirstName + ' ' + ISNULL(MiddleName, ' ') + ' ' + LastName AS [Full Name]
FROM Employees
WHERE Salary IN (25000, 14000, 12500, 23600)

GO


USE SoftUni
--11
SELECT FirstName, LastName
FROM Employees
WHERE dbo.Employees.ManagerID IS NULL

GO


USE SoftUni
--12
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary > 50000
ORDER BY Salary DESC

GO


USE SoftUni
--13
SELECT TOP (5) FirstName, 
               LastName
FROM Employees
ORDER BY Salary DESC;

GO


USE SoftUni
--14
SELECT FirstName, 
       LastName
FROM Employees
WHERE DepartmentID <> 4;

GO


USE SoftUni
--15
SELECT *
FROM Employees
ORDER BY Salary DESC, 
         FirstName ASC, 
         LastName DESC, 
         MiddleName ASC;

GO



USE SoftUni
--16
GO
CREATE VIEW V_EmployeesSalaries  AS
SELECT FirstName, LastName, Salary FROM Employees

GO



USE SoftUni
--17
GO
CREATE VIEW V_EmployeeNameJobTitle AS
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' +  LastName AS [Full Name], JobTitle FROM Employees
GO


USE SoftUni
--18
SELECT DISTINCT JobTitle FROM Employees

GO



USE SoftUni
--19
SELECT TOP(10) * FROM Projects 
ORDER BY StartDate, [Name]

GO



USE SoftUni
--20
SELECT TOP(7) dbo.Employees.FirstName, dbo.Employees.LastName, dbo.Employees.HireDate FROM Employees 
ORDER BY HireDate DESC

GO



USE SoftUni
--21
UPDATE Employees
SET    Salary *= 1.12
WHERE  DepartmentID IN (1, 2, 4, 11)

SELECT Salary FROM Employees

GO


USE Geography
--22
SELECT PeakName FROM dbo.Peaks
ORDER BY dbo.Peaks.PeakName

GO


USE Geography
--23
SELECT TOP(30) CountryName, [Population] FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY [Population] DESC

GO


USE Geography
--23
SELECT CountryName, 
       CountryCode,
       CASE
           WHEN CurrencyCode = 'EUR'
           THEN 'Euro'
           ELSE 'Not Euro'
       END AS [Currency]
FROM Countries
ORDER BY CountryName;

GO


USE Diablo
--25
SELECT Name FROM Characters
ORDER BY Name

GO

