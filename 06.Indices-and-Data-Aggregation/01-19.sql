USE Gringotts;
--1
SELECT COUNT(Id) AS [Count]
FROM dbo.WizzardDeposits wd;
GO


USE Gringotts;
--2
SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM dbo.WizzardDeposits wd;
GO


USE Gringotts;
--3
SELECT wd.DepositGroup, 
       MAX(wd.MagicWandSize) AS LongestMagicWand
FROM dbo.WizzardDeposits wd
GROUP BY wd.DepositGroup;
GO


USE Gringotts;
--4
SELECT TOP (2) wd.DepositGroup
FROM dbo.WizzardDeposits wd
GROUP BY wd.DepositGroup
ORDER BY AVG(wd.MagicWandSize) ASC;
GO


USE Gringotts;
--5
SELECT wd.DepositGroup, 
       SUM(wd.DepositAmount) AS TotalSum
FROM dbo.WizzardDeposits wd
GROUP BY wd.DepositGroup;
GO


USE Gringotts;
--6
SELECT wd.DepositGroup, 
       SUM(wd.DepositAmount) AS TotalSum
FROM dbo.WizzardDeposits wd
WHERE wd.MagicWandCreator = 'Ollivander family'
GROUP BY wd.DepositGroup;
GO


USE Gringotts;
--7
SELECT wd.DepositGroup, 
       SUM(wd.DepositAmount) AS TotalSum
FROM dbo.WizzardDeposits wd
WHERE wd.MagicWandCreator = 'Ollivander family'
GROUP BY wd.DepositGroup
HAVING SUM(wd.DepositAmount) < 150000
ORDER BY TotalSum DESC;
GO


USE Gringotts;
--8
SELECT wd.DepositGroup, 
       wd.MagicWandCreator, 
       MIN(wd.DepositCharge) AS MinDepositCharge
FROM dbo.WizzardDeposits wd
GROUP BY wd.DepositGroup, 
         wd.MagicWandCreator
ORDER BY wd.MagicWandCreator, 
         wd.DepositGroup;
GO


USE Gringotts;
--9
SELECT AgeGroups, 
       COUNT(ag.AgeGroups)
FROM
(
    SELECT CASE
               WHEN wd.Age BETWEEN 0 AND 10
               THEN '[0-10]'
               WHEN wd.Age BETWEEN 11 AND 20
               THEN '[11-20]'
               WHEN wd.Age BETWEEN 21 AND 30
               THEN '[21-30]'
               WHEN wd.Age BETWEEN 31 AND 40
               THEN '[31-40]'
               WHEN wd.Age BETWEEN 41 AND 50
               THEN '[41-50]'
               WHEN wd.Age BETWEEN 51 AND 60
               THEN '[51-60]'
               WHEN wd.Age >= 60
               THEN '[61+]'
           END AS AgeGroups
    FROM dbo.WizzardDeposits AS wd
) AS ag
GROUP BY AgeGroups;
GO


USE Gringotts;
--10
SELECT LEFT(wd.FirstName, 1) AS FirstLetter
FROM dbo.WizzardDeposits wd
WHERE wd.DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)
ORDER BY FirstLetter;

GO


USE Gringotts
--11
SELECT wd.DepositGroup, 
       wd.IsDepositExpired, 
       AVG(wd.DepositInterest) AS AverageInterest
FROM dbo.WizzardDeposits wd
WHERE wd.DepositStartDate > '01/01/1985'
GROUP BY wd.DepositGroup, 
         wd.IsDepositExpired
ORDER BY wd.DepositGroup DESC, 
         wd.IsDepositExpired ASC;

GO


USE Gringotts
--12
SELECT SUM(tableResult.[Difference])
FROM
(
    SELECT wd.FirstName as HostWizard, 
           wd.DepositAmount as HostDeposit,
		   Lead(wd.FirstName) OVER (ORDER BY wd.Id) as GuestWizard, 
           Lead(wd.DepositAmount) OVER (ORDER BY wd.Id) as GuestDeposit, 
           wd.DepositAmount - Lead(wd.DepositAmount) OVER (ORDER BY wd.Id) as [Difference]
    FROM dbo.WizzardDeposits wd        
)	
 AS tableResult;

GO


USE SoftUni
--13
SELECT e.DepartmentID, Sum(e.Salary) AS [TotalSalary]
FROM dbo.Employees e
GROUP BY e.DepartmentID;

GO


USE SoftUni
--14
SELECT e.DepartmentID, Min(e.Salary) AS MinimumSalary
FROM dbo.Employees e
WHERE e.DepartmentID IN (2, 5, 7) AND e.HireDate > '01/01/2000'
GROUP BY e.DepartmentID;

GO


USE SoftUni
--15
SELECT *
INTO newSalaryTable
FROM dbo.Employees e
WHERE e.Salary > 30000;

DELETE FROM newSalaryTable
WHERE ManagerID = 42;

UPDATE newSalaryTable
  SET 
      Salary+=5000
WHERE DepartmentID = 1;

SELECT nst.DepartmentID, 
       AVG(Salary) AS AverageSalary
FROM newSalaryTable nst
GROUP BY nst.DepartmentID;

GO


USE SoftUni
--16
SELECT e.DepartmentID, 
       MAX(e.Salary) AS MaxSalary
FROM dbo.Employees e
GROUP BY e.DepartmentID
HAVING MAX(e.Salary) NOT BETWEEN 30000 AND 70000;

GO


USE SoftUni
--17
SELECT count(*)
FROM dbo.Employees e
WHERE e.ManagerID IS NULL

GO


USE SoftUni
--18
SELECT DISTINCT 
       DepartmentID, 
       Salary AS ThirdHighestSalary
FROM
(
    SELECT e.DepartmentID, 
           e.Salary, 
           DENSE_RANK() OVER (PARTITION BY e.DepartmentID
           ORDER BY e.Salary DESC) AS RankDep
    FROM dbo.Employees e
) AS rankTable
WHERE RankDep = 3;

GO


USE SoftUni
--19
SELECT TOP (10) e1.FirstName, 
                e1.LastName, 
                e1.DepartmentID
FROM dbo.Employees e1
WHERE e1.Salary >
(
    SELECT AVG(e2.Salary) AS AvgSalary
    FROM dbo.Employees e2
    WHERE e1.DepartmentID = e2.DepartmentID
    GROUP BY e2.DepartmentID
)
ORDER BY e1.DepartmentID;

GO
