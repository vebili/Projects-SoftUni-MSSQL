--1
USE SoftUni

SELECT TOP (5) e.EmployeeId, 
               e.JobTitle, 
               e.AddressID, 
               a.AddressText
FROM dbo.Employees e
     JOIN dbo.Addresses a ON e.AddressID = a.AddressID
ORDER BY e.AddressID;

GO

--2
USE SoftUni

SELECT TOP (50) e.FirstName, 
               e.LastName, 
               t.[Name] Town, 
               a.AddressText
FROM dbo.Employees e
     JOIN dbo.Addresses a ON e.AddressID = a.AddressID
	 JOIN dbo.Towns t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName;

GO

--3
USE SoftUni

SELECT e.EmployeeID, 
       e.FirstName, 
       e.LastName, 
       d.[Name] DepartmentName
FROM dbo.Employees e
     JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID;

GO

--4
USE SoftUni

SELECT top(5) e.EmployeeID, 
       e.FirstName, 
       e.Salary, 
       d.[Name] DepartmentName
FROM dbo.Employees e
     JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID;

GO

--5
USE SoftUni

SELECT TOP (3) e.EmployeeID, 
               e.FirstName
FROM dbo.Employees e
     LEFT JOIN dbo.EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID;

GO

--6
USE SoftUni

SELECT e.FirstName, 
       e.LastName, 
       e.HireDate, 
       d.[Name] DepartmentName
FROM dbo.Employees e
     JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1.1.1999'
      AND d.[Name] IN('Sales', 'Finance')
ORDER BY e.HireDate;

GO

--7
USE SoftUni

SELECT TOP (5) e.EmployeeID, 
               e.FirstName, 
               p.[Name] ProjectName
FROM dbo.Employees e
     JOIN dbo.EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
     JOIN dbo.Projects p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '08-13-2002'
      AND p.EndDate IS NULL
ORDER BY e.EmployeeID;

GO

--8
USE SoftUni

SELECT TOP (5) e.EmployeeID, 
               e.FirstName,
               CASE
                   WHEN DATEPART(year, p.StartDate) >= 2005
                   THEN NULL
                   ELSE p.[Name]
               END AS ProjectName
FROM dbo.Employees e
     JOIN dbo.EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
     JOIN dbo.Projects p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24
ORDER BY e.EmployeeID;

GO

SELECT TOP (5) e.EmployeeID, 
               e.FirstName, 
               IIF(DATEPART(year, p.StartDate) >= 2005, NULL, p.[Name]) AS ProjectName
FROM dbo.Employees e
     JOIN dbo.EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
     JOIN dbo.Projects p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24
ORDER BY e.EmployeeID;

GO

--9
USE SoftUni

SELECT e.EmployeeID, 
       e.FirstName, 
       e.ManagerID, 
       m.FirstName ManagerName
FROM dbo.Employees e
     JOIN dbo.Employees m ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID;

GO

--10
USE SoftUni

SELECT TOP (50) e.EmployeeID, 
                CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName, 
                CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName, 
                d.[Name] DepartmentName
FROM dbo.Employees e
     JOIN dbo.Employees m ON e.ManagerID = m.EmployeeID
     JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;

GO

--11
USE SoftUni

WITH CTE_AVG_Salary_Departments(AVGSalary)
     AS (SELECT AVG(e.Salary)
         FROM dbo.Employees e
         GROUP BY e.DepartmentID)
     SELECT MIN(AVGSalary)
     FROM CTE_AVG_Salary_Departments casd;

GO

--12
USE Geography

SELECT c.CountryCode, 
       m.MountainRange, 
       p.PeakName, 
       p.Elevation
FROM dbo.Countries c
     JOIN dbo.MountainsCountries mc ON c.CountryCode = mc.CountryCode
     JOIN dbo.Mountains m ON mc.MountainId = m.Id
     JOIN dbo.Peaks p ON m.Id = p.MountainId
WHERE c.CountryCode = 'BG'
      AND p.Elevation > 2835
ORDER BY p.Elevation DESC;

GO

--13
USE Geography

SELECT mc.CountryCode, 
       COUNT(mc.MountainId)
FROM dbo.MountainsCountries mc 
WHERE mc.CountryCode IN('BG', 'RU', 'US')
GROUP BY mc.CountryCode;

SELECT c.CountryCode, 
       COUNT(m.MountainRange)
FROM dbo.Countries c
     JOIN dbo.MountainsCountries mc ON c.CountryCode = mc.CountryCode
     JOIN dbo.Mountains m ON mc.MountainId = m.Id
WHERE c.CountryCode in ('BG', 'RU', 'US')
GROUP BY c.CountryCode

GO

--14
USE Geography

SELECT TOP (5) c.CountryName, 
               r.RiverName
FROM dbo.Countries c
     LEFT JOIN dbo.CountriesRivers cr ON c.CountryCode = cr.CountryCode
     LEFT JOIN dbo.Rivers r ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName;

GO

--15
USE Geography

WITH CTE_MostUsedCurrency
     AS (SELECT c.ContinentCode, 
                c.CurrencyCode, 
                COUNT(c.CurrencyCode) AS [CurrencyUsage], 
                DENSE_RANK() OVER(PARTITION BY c.ContinentCode
                ORDER BY COUNT(c.CurrencyCode) DESC) AS [CurrencyRank]
         FROM dbo.Countries c
         GROUP BY c.ContinentCode, 
                  c.CurrencyCode
         HAVING COUNT(c.CurrencyCode) > 1)


     SELECT cmuc.ContinentCode, 
            cmuc.CurrencyCode, 
            cmuc.CurrencyUsage
     FROM CTE_MostUsedCurrency cmuc
     WHERE cmuc.CurrencyRank = 1
     ORDER BY cmuc.ContinentCode;

GO

--16
USE Geography

WITH CTE_Countries_NullMountains
     AS (SELECT COUNT(*) AS CCode
         FROM dbo.Countries c
              LEFT JOIN dbo.MountainsCountries mc ON c.CountryCode = mc.CountryCode
              LEFT JOIN dbo.Mountains m ON mc.MountainId = m.Id
         GROUP BY c.CountryCode, 
                  m.MountainRange
         HAVING m.MountainRange IS NULL)
     SELECT COUNT(ccnm.CCode) AS CountryCode
     FROM CTE_Countries_NullMountains ccnm
     GROUP BY ccnm.CCode;

GO

SELECT COUNT(*) - COUNT(mc.MountainId) AS CountryCode
FROM dbo.Countries c
     LEFT JOIN dbo.MountainsCountries mc ON c.CountryCode = mc.CountryCode;

GO

SELECT COUNT(*) AS CountryCode
FROM dbo.Countries c
     LEFT JOIN dbo.MountainsCountries mc ON c.CountryCode = mc.CountryCode
WHERE mc.MountainId IS NULL;

GO

--17
USE Geography

SELECT TOP (5) c.CountryName, 
             MAX(p.Elevation) AS [HighestPeakElevation], 
             MAX(r.Length) AS [LongestRiverLength]
FROM Countries c
     FULL JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
     FULL JOIN Peaks p ON p.MountainId = mc.MountainId
     FULL JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
     FULL JOIN Rivers r ON r.Id = cr.RiverId
GROUP BY c.CountryName
ORDER BY [HighestPeakElevation] DESC, 
         [LongestRiverLength] DESC, 
         c.CountryName;

GO

--18
USE Geography

SELECT TOP 5 c.CountryName, 
             ISNULL(p.PeakName, '(no highest peak)') AS [Highest Peak Name], 
             ISNULL(p.Elevation, 0) AS [Highest Peak Elevation], 
             ISNULL(m.MountainRange, '(no mountain)') AS [Mountain]
FROM Countries c
     LEFT JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
     LEFT JOIN Mountains m ON m.Id = mc.MountainId
     LEFT JOIN Peaks p ON p.MountainId = m.Id
ORDER BY c.CountryName, 
         p.Elevation, 
         p.PeakName;


WITH CTE_CountryPeak_Elevation
     AS (SELECT c.CountryName, 
                ISNULL(p.PeakName, '(no highest peak)') AS [Highest Peak Name], 
                ISNULL(p.Elevation, 0) AS [Highest Peak Elevation], 
                ISNULL(m.MountainRange, '(no mountain)') AS [Mountain], 
                DENSE_RANK() OVER(PARTITION BY c.CountryName
                ORDER BY p.Elevation DESC) AS ElevationRank
         FROM Countries c
              LEFT JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
              LEFT JOIN Mountains m ON m.Id = mc.MountainId
              LEFT JOIN Peaks p ON p.MountainId = m.Id)
     SELECT TOP (5) ccpe.CountryName, 
                    ccpe.[Highest Peak Name], 
                    ccpe.[Highest Peak Elevation], 
                    ccpe.[Mountain]
     FROM CTE_CountryPeak_Elevation ccpe
     WHERE ccpe.ElevationRank = 1
     ORDER BY ccpe.CountryName, 
              ccpe.[Highest Peak Name] DESC;


GO
