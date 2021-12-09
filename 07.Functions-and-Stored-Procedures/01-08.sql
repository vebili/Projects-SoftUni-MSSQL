--1
USE SoftUni
GO

CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
     SELECT e.FirstName, 
            e.LastName
     FROM dbo.Employees e
     WHERE e.Salary > 35000;
GO

EXEC usp_GetEmployeesSalaryAbove35000

--2
USE SoftUni
GO

CREATE PROC usp_GetEmployeesSalaryAboveNumber(@MinWage DECIMAL(18, 4))
AS
     SELECT e.FirstName, 
            e.LastName
     FROM dbo.Employees e
     WHERE e.Salary >= @MinWage;
GO

EXEC usp_GetEmployeesSalaryAboveNumber 48100


--3
USE SoftUni
GO

CREATE PROC usp_GetTownsStartingWith (@StartString NVARCHAR(10))
AS
     SELECT t.[Name] AS Town
     FROM dbo.Towns t
     WHERE t.[Name] LIKE(@StartString + '%');
GO

EXEC usp_GetTownsStartingWith b

GO

--4
USE SoftUni
GO

CREATE PROC usp_GetEmployeesFromTown(@TownName NVARCHAR(10))
AS
     SELECT e.FirstName, 
            e.LastName
     FROM dbo.Employees e
          JOIN dbo.Addresses a ON e.AddressID = a.AddressID
          JOIN dbo.Towns t ON a.TownID = t.TownID
     WHERE t.[Name] = @TownName;
GO

EXEC usp_GetEmployeesFromTown Sofia

GO

--5
USE SoftUni
GO

CREATE FUNCTION ufn_GetSalaryLevel(@Salary INT) RETURNS NVARCHAR(10) AS BEGIN
DECLARE @salaryLevel VARCHAR(10);
IF (@Salary < 30000)
  SET @salaryLevel = 'Low';
ELSE IF(@Salary >= 30000 AND @Salary <= 50000)
  SET @salaryLevel = 'Average';
ELSE
  SET @salaryLevel = 'High';
RETURN @salaryLevel;
END;

GO

--6
USE SoftUni
GO

CREATE PROC usp_EmployeesBySalaryLevel (@SalaryLevel VARCHAR(7))
AS
     SELECT e.FirstName, 
            e.LastName
     FROM dbo.Employees e
     WHERE dbo.ufn_GetSalaryLevel(e.Salary) = @SalaryLevel;
GO

EXEC usp_EmployeesBySalaryLevel 'High'

GO

--7
USE SoftUni
GO

CREATE FUNCTION ufn_IsWordComprised
(@SetOfLetters NVARCHAR(MAX), 
 @Word         NVARCHAR(MAX)
)
RETURNS BIT
AS
     BEGIN
         DECLARE @count INT= 1;
         WHILE(@count <= LEN(@Word))
             BEGIN
                 DECLARE @letter CHAR= SUBSTRING(@Word, @count, 1);
                 DECLARE @indexLetter INT= CHARINDEX(@letter, @SetOfLetters);
                 IF(@indexLetter <= 0)
                     BEGIN
                         RETURN 0;
                 END;
                 SET @count+=1;
             END;
         RETURN 1;
     END;
GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia');

GO


--8
USE SoftUni
GO

CREATE PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
AS
     DELETE FROM dbo.EmployeesProjects
     WHERE EmployeeID IN
     (
         SELECT e.EmployeeID
         FROM dbo.Employees e
         WHERE e.DepartmentID = @departmentId
     );

     UPDATE dbo.Employees
       SET 
           ManagerID = NULL
     WHERE ManagerID IN
     (
         SELECT e.EmployeeID
         FROM dbo.Employees e
         WHERE e.DepartmentID = @departmentId
     );

     ALTER TABLE dbo.Departments ALTER COLUMN ManagerID INT;

     UPDATE dbo.Departments
       SET 
           ManagerID = NULL
     WHERE DepartmentID = @departmentId;

     DELETE FROM dbo.Employees
     WHERE DepartmentID = @departmentId;

     DELETE FROM dbo.Departments
     WHERE DepartmentID = @departmentId;

     SELECT COUNT(*)
     FROM dbo.Employees e
     WHERE DepartmentID = @departmentId;
    
GO
