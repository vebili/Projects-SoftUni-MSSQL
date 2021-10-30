--CREATE DATABASE ReportService
--USE ReportService
--1
CREATE TABLE Users
(Id         INT
 PRIMARY KEY IDENTITY, 
 Username   NVARCHAR(30) NOT NULL UNIQUE, 
 [Password] NVARCHAR(50) NOT NULL, 
 [Name]     NVARCHAR(50), 
 Gender     CHAR(1) CHECK(Gender IN('M', 'F')), 
 BirthDate  DATETIME2, 
 Age        INT, 
 Email      NVARCHAR(50) NOT NULL
);

CREATE TABLE Departments
(Id     INT
 PRIMARY KEY IDENTITY, 
 [Name] NVARCHAR(50) NOT NULL
);

CREATE TABLE Employees
(Id           INT
 PRIMARY KEY IDENTITY, 
 FirstName    NVARCHAR(25), 
 LastName     NVARCHAR(25), 
 Gender       CHAR(1) CHECK(Gender IN('M', 'F')), 
 BirthDate    DATETIME2, 
 Age          INT, 
 DepartmentId INT NOT NULL
                  FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE Categories
(Id           INT
 PRIMARY KEY IDENTITY, 
 [Name]       NVARCHAR(50) NOT NULL, 
 DepartmentId INT NOT NULL
                  FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE [Status]
(Id    INT
 PRIMARY KEY IDENTITY, 
 Label NVARCHAR(30) NOT NULL
);

CREATE TABLE Reports
(Id            INT
 PRIMARY KEY IDENTITY, 
 CategoryId    INT NOT NULL
                   FOREIGN KEY REFERENCES Categories(Id), 
 StatusId      INT NOT NULL
                   FOREIGN KEY REFERENCES [Status](Id), 
 OpenDate      DATETIME2 NOT NULL, 
 CloseDate     DATETIME2, 
 [Description] NVARCHAR(200), 
 UserId        INT NOT NULL
                   FOREIGN KEY REFERENCES Users(Id), 
 EmployeeId    INT FOREIGN KEY REFERENCES Employees(Id)
);
GO

--2
INSERT INTO Employees
				(Firstname, Lastname, Gender, Birthdate, DepartmentId)
VALUES
				(N'Marlo', N'OMalley', 'M', '09/21/1958', '1'),
				(N'Niki', N'Stanaghan', 'F', '11/26/1969', '4'),
				(N'Ayrton', 'N''Senna', 'M', '03/21/1960 ', '9'),
				(N'Ronnie', N'Peterson', 'M', '02/14/1944', '9'),
				(N'Giovanna', N'Amati', 'F', '07/20/1959', '5');

INSERT INTO Reports
(CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId)
VALUES
('1', '1', '04/13/2017', NULL, N'Stuck Road on Str.133', '6', '2'),
('6', '3', '09/05/2015', '12/06/2015', N'Charity trail running', '3', '5'),
('14', '2', '09/07/2015', NULL, N'Falling bricks on Str.58', '5', '2'),
('4', '3', '07/03/2017', '07/06/2017', N'Cut off streetlight on Str.11', '1', '1');

GO

--3
UPDATE Reports
  SET 
      StatusId = 2
WHERE StatusId = 1
      AND CategoryId = 4;
GO

--4
DELETE Reports
WHERE StatusId = 4;
GO

--5.	Users by Age
SELECT u.Username, 
       u.Age
FROM dbo.Users u
ORDER BY u.Age, 
         u.Username DESC;
GO

--6.	Unassigned Reports
SELECT r.[Description], 
       r.OpenDate
FROM dbo.Reports r
WHERE r.EmployeeId IS NULL
ORDER BY r.OpenDate, 
         r.[Description];
GO

--7.	Employees & Reports
SELECT e.FirstName, 
       e.LastName, 
       r.[Description], 
       FORMAT(r.OpenDate, 'yyyy-MM-dd') Opendate
FROM dbo.Employees e
     JOIN dbo.Reports r ON e.Id = r.EmployeeId
ORDER BY e.Id, 
         r.OpenDate, 
         r.Id;
GO

--8.	Most reported Category
SELECT c.Name CategoryName, 
       COUNT(r.Id) ReportsNumber
FROM dbo.Categories c
     LEFT JOIN dbo.Reports r ON c.Id = r.CategoryId
GROUP BY c.Name
ORDER BY ReportsNumber DESC, 
         CategoryName;
GO

--9.	Employees in Category
SELECT c.Name CategoryName, 
       COUNT(e.Id) [Employees Number]
FROM dbo.Categories c
     JOIN dbo.Departments d ON c.DepartmentId = d.Id
     JOIN dbo.Employees e ON d.Id = e.DepartmentId
GROUP BY c.Name
ORDER BY c.Name;
GO

--10.	Users per Employee 
SELECT CONCAT(e.FirstName, ' ', e.LastName) [Name], 
       COUNT(DISTINCT r.EmployeeId) [Users Number]
FROM dbo.Employees e
     LEFT JOIN dbo.Reports r ON e.Id = r.EmployeeId
GROUP BY e.FirstName, 
         e.LastName
ORDER BY [Users Number] DESC, 
         [Name];
GO

--11.	Emergency Patrol -- Path is through categories to departments,
						 -- because Report can have EmplyeeID that is NULL,
						 -- So report is assigned to department first
						 -- (through category) then from department to
						 -- Employee
SELECT r.OpenDate, 
       r.[Description], 
       u.Email [Reporter Email]
FROM dbo.Reports r
     JOIN dbo.Categories c ON r.CategoryId = c.Id
	 JOIN dbo.Departments d ON c.DepartmentId = d.Id
     JOIN dbo.Users u ON r.UserId = u.Id
WHERE r.CloseDate IS NULL
      AND LEN(r.[Description]) > 20
      AND r.[Description] LIKE '%str%'
      AND d.Name IN('Infrastructure', 'Emergency', 'Roads Maintenance')
ORDER BY r.OpenDate, 
         [Reporter Email], 
         r.Id;
GO

--12.	Birthday Report
SELECT DISTINCT 
       c.Name [Category Name]
FROM dbo.Reports r
     JOIN dbo.Categories c ON c.Id = r.CategoryId
     JOIN dbo.Users u ON r.UserId = u.Id
WHERE DAY(r.OpenDate) = DAY(u.BirthDate)
      AND MONTH(R.Opendate) = MONTH(U.Birthdate)
ORDER BY [Category Name];
GO

--13.	Numbers Coincidence
SELECT DISTINCT u.Username
FROM dbo.Users u
     JOIN dbo.Reports r ON u.Id = r.UserId
     JOIN dbo.Categories c ON r.CategoryId = c.Id
WHERE u.Username LIKE CONCAT(c.Id, '%')
      OR u.Username LIKE CONCAT('%', c.Id)
--WHERE(Username LIKE '[0-9]_%'
--      AND CAST(c.id AS VARCHAR) = LEFT(username, 1))
--     OR (Username LIKE '%_[0-9]'
--         AND CAST(c.id AS VARCHAR) = RIGHT(username, 1))
ORDER BY u.Username;
GO

--14.	Open/Closed Statistics
SELECT CONCAT(e.FirstName, ' ', e.LastName) [Name], 
       CONCAT(ISNULL(c.ClosedSum, 0), '/', ISNULL(o.OpenedSum, 0)) [Closed Open Reports]
FROM dbo.Employees e
     JOIN
(
    SELECT EmployeeId, 
           COUNT(r.Id) AS OpenedSum
    FROM Reports r
    WHERE YEAR(r.OpenDate) = 2016
    GROUP BY EmployeeId
) AS o ON e.Id = o.EmployeeId
     LEFT JOIN
(
    SELECT EmployeeId, 
           COUNT(r.Id) AS ClosedSum
    FROM Reports r
    WHERE YEAR(r.CloseDate) = 2016
    GROUP BY EmployeeId
) AS c ON c.EmployeeId = e.Id
GROUP BY e.FirstName, 
         e.LastName,
		 o.OpenedSum,
		 c.ClosedSum
ORDER BY [Name];		 
GO

--15.	Average Closing Time
SELECT d.Name, 
       ISNULL(CAST(AVG(DATEDIFF(day, r.OpenDate, r.CloseDate)) AS VARCHAR(7)), 'no info') AS [Average Duration]
FROM dbo.Departments d
     JOIN dbo.Categories c ON d.Id = c.DepartmentId
     LEFT JOIN dbo.Reports r ON c.Id = r.CategoryId
GROUP BY d.Name
ORDER BY d.Name;
GO

--16.	Favorite Categories
WITH CTE_PercentageDistribution
     AS (SELECT d.Name AS Department, 
                c.Name AS Category,
				CAST(
					ROUND(
						(COUNT(*) OVER(PARTITION BY c.Id) * 100.00 
							/ COUNT(*) OVER(PARTITION BY d.Id)), 0) AS INT) 
										AS Percentage
         FROM Categories AS c
              JOIN Reports AS r ON r.Categoryid = c.Id
              JOIN Departments AS d ON d.Id = c.Departmentid)

SELECT Department, 
       Category, 
       Percentage
FROM CTE_PercentageDistribution
GROUP BY Department, 
         Category, 
         [Percentage]
ORDER BY Department, 
         Category, 
         [Percentage];
GO

--17.	Employee’s Load
CREATE FUNCTION udf_GetReportsCount
(@employeeId INT, 
 @statusId   INT
)
RETURNS INT
     BEGIN
         RETURN
         (
             SELECT COUNT(r.Id)
             FROM dbo.Reports r
             WHERE r.EmployeeId = @employeeId
                   AND r.StatusId = @statusId
         );
     END;
GO

--18.	Assign Employee
CREATE PROC usp_AssignEmployeeToReport
(@employeeId INT, 
 @reportId   INT
)
AS
    BEGIN TRAN;
        DECLARE @empDepartmentId INT=
        (
            SELECT e.DepartmentId
            FROM dbo.Employees e
            WHERE e.Id = @employeeId
        );

		IF(@empDepartmentId IS NULL)
            BEGIN
                ROLLBACK;
                RAISERROR('Invalid employee Id!', 16, 2);
                RETURN;
        END;

        DECLARE @repDepartmentId INT=
        (
            SELECT c.DepartmentId
            FROM dbo.Reports r
                 JOIN dbo.Categories c ON r.CategoryId = c.Id
            WHERE r.Id = @reportId
        );

		IF(@repDepartmentId IS NULL)
            BEGIN
                ROLLBACK;
                RAISERROR('Invalid report Id!', 16, 3);
                RETURN;
        END;

        IF( @employeeId IS NOT NULL 
			AND @empDepartmentId <> @repDepartmentId)
            BEGIN
                ROLLBACK;
                RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1);
                RETURN;
        END;

        UPDATE dbo.Reports
          SET 
              dbo.Reports.EmployeeId = @employeeId
        WHERE dbo.Reports.Id = @reportId;
        COMMIT;
GO

--19.	Close Reports
CREATE TRIGGER tr_CloseReport ON Reports
AFTER UPDATE
AS
BEGIN
	UPDATE Reports
	SET StatusId = (SELECT Id FROM [Status] WHERE Label = 'completed')
	WHERE Id IN (SELECT Id FROM inserted
			     WHERE Id IN (SELECT Id FROM deleted
						      WHERE CloseDate IS NULL)
			           AND CloseDate IS NOT NULL)   
END;
GO

--20.	Categories Revision
 WITH CTE_FindInProgressAndWaiting
     AS (SELECT r.CategoryId, 
                SUM(CASE
                        WHEN s.Label = 'in progress' THEN 1
                        ELSE 0
                    END) AS InProgressCount, 
                SUM(CASE
                        WHEN s.Label = 'waiting' THEN 1
                        ELSE 0
                    END) AS WaitingCount
         FROM Reports AS r
              JOIN [Status] AS s ON s.Id = r.StatusId
         WHERE s.Label IN('waiting', 'in progress')
         GROUP BY r.CategoryId)
		 
SELECT c.Name, 
       COUNT(r.Id) AS ReportsNumber,
       CASE
           WHEN cte.InProgressCount > cte.WaitingCount THEN 'in progress'
           WHEN cte.InProgressCount < cte.WaitingCount THEN 'waiting'
           ELSE 'equal'
       END AS MainStatus
FROM Reports AS r
     JOIN Categories AS c ON c.Id = r.CategoryId
     JOIN [Status] AS s ON s.Id = r.StatusId
     JOIN CTE_FindInProgressAndWaiting AS cte ON cte.CategoryId = c.Id
WHERE s.Label IN('waiting', 'in progress')
GROUP BY C.Name,
         CASE
             WHEN cte.InProgressCount > cte.WaitingCount THEN 'in progress'
             WHEN cte.InProgressCount < cte.WaitingCount THEN 'waiting'
             ELSE 'equal'
         END
ORDER BY C.Name, 
         ReportsNumber, 
         MainStatus;
GO