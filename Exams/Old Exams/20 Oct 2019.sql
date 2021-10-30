--CREATE DATABASE [Service]
--USE [Service]
--01. DDL
CREATE TABLE Users
(Id         INT
 PRIMARY KEY IDENTITY, 
 Username   VARCHAR(30) NOT NULL UNIQUE, 
 [Password] VARCHAR(50) NOT NULL, 
 [Name]     VARCHAR(50),  
 BirthDate  DATETIME2, 
 Age        INT CHECK (Age BETWEEN 14 AND 110), 
 Email      VARCHAR(50) NOT NULL
);

CREATE TABLE Departments
(Id     INT
 PRIMARY KEY IDENTITY, 
 [Name] VARCHAR(50) NOT NULL
);

CREATE TABLE Employees
(Id           INT
 PRIMARY KEY IDENTITY, 
 FirstName    VARCHAR(25), 
 LastName     VARCHAR(25), 
 BirthDate    DATETIME2, 
 Age          INT CHECK (Age BETWEEN 18 AND 110), 
 DepartmentId INT NOT NULL
                  FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE Categories
(Id           INT
 PRIMARY KEY IDENTITY, 
 [Name]       VARCHAR(50) NOT NULL, 
 DepartmentId INT NOT NULL
                  FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE [Status]
(Id    INT
 PRIMARY KEY IDENTITY, 
 Label VARCHAR(30) NOT NULL
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
 [Description] VARCHAR(200), 
 UserId        INT NOT NULL
                   FOREIGN KEY REFERENCES Users(Id), 
 EmployeeId    INT FOREIGN KEY REFERENCES Employees(Id)
);
GO

--02. Insert
INSERT INTO Employees
				(Firstname, Lastname, Birthdate, DepartmentId)
VALUES
				('Marlo', 'O''Malley', '09/21/1958', '1'),
				('Niki', 'Stanaghan', '11/26/1969', '4'),
				('Ayrton', 'Senna', '03/21/1960 ', '9'),
				('Ronnie', 'Peterson', '02/14/1944', '9'),
				('Giovanna', 'Amati', '07/20/1959', '5');

INSERT INTO Reports
(CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId)
VALUES
('1', '1', '04/13/2017', NULL, 'Stuck Road on Str.133', '6', '2'),
('6', '3', '09/05/2015', '12/06/2015', 'Charity trail running', '3', '5'),
('14', '2', '09/07/2015', NULL, 'Falling bricks on Str.58', '5', '2'),
('4', '3', '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', '1', '1');

GO

--03. Update
UPDATE dbo.Reports
  SET 
      dbo.Reports.CloseDate = GETDATE()
WHERE dbo.Reports.CloseDate IS NULL;
GO

--04. Delete
DELETE Reports
WHERE StatusId = 4;
GO

--05. Unassigned Reports
SELECT r.[Description], 
       FORMAT(r.OpenDate, 'dd-MM-yyyy')
FROM dbo.Reports r
WHERE r.EmployeeId IS NULL
ORDER BY r.OpenDate, 
         r.[Description];
GO

--06. Reports & Categories
SELECT r.[Description], 
       c.[Name]
FROM dbo.Reports r
     JOIN dbo.Categories c ON r.CategoryId = c.Id
ORDER BY r.[Description], 
         c.[Name];
GO

--07. Most Reported Category
SELECT TOP (5) c.Name CategoryName, 
               COUNT(r.Id) ReportsNumber
FROM dbo.Categories c
     LEFT JOIN dbo.Reports r ON c.Id = r.CategoryId
GROUP BY c.Name
ORDER BY ReportsNumber DESC, 
         CategoryName;
GO

--08. Birthday Report
SELECT DISTINCT 
       u.Username, 
       c.Name [Category Name]
FROM dbo.Reports r
     JOIN dbo.Categories c ON c.Id = r.CategoryId
     JOIN dbo.Users u ON r.UserId = u.Id
WHERE DAY(r.OpenDate) = DAY(u.BirthDate)
      AND MONTH(R.Opendate) = MONTH(U.Birthdate)
ORDER BY u.Username, 
         [Category Name];
GO

--09. User per Employee
SELECT CONCAT(e.FirstName, ' ', e.LastName) [FullName], 
       COUNT(r.EmployeeId) [Users Number]
FROM dbo.Employees e
     LEFT JOIN dbo.Reports r ON e.Id = r.EmployeeId
GROUP BY CONCAT(e.FirstName, ' ', e.LastName)
ORDER BY [Users Number] DESC, 
         [FullName];
GO

--10. Full Info
SELECT ISNULL(e.FirstName + ' ' + e.LastName, 'None') [Employee], 
       ISNULL(d.Name, 'None') [Department], 
       ISNULL(c2.Name, 'None') [Category], 
       ISNULL(r.Description, 'None') [Description], 
       ISNULL(FORMAT(r.OpenDate, 'dd.MM.yyyy'), 'None') [OpenDate], 
       ISNULL(s.Label, 'None') [Status], 
       ISNULL(u.[Name], 'None') [User]
FROM dbo.Reports r 
	full JOIN dbo.Employees e ON r.EmployeeId = e.Id
	left JOIN dbo.Departments d ON e.DepartmentId = d.Id
	JOIN dbo.Categories c2 ON r.CategoryId = c2.Id
	 full JOIN dbo.Users u ON r.UserId = u.Id
     full JOIN dbo.[Status] s ON r.StatusId = s.Id
WHERE r.Id IS NOT NULL
ORDER BY e.FirstName DESC, 
         e.LastName DESC, 
         [Department], 
         [Category], 
         [Description], 
         [OpenDate], 
         [Status], 
         [User];


SELECT IIF(u.Name IS NULL, 'None', u.Name) [Employee] FROM dbo.Reports r LEFT JOIN dbo.Users u ON r.UserId = u.Id
GO

--11. Hours to Complete
CREATE FUNCTION udf_HoursToComplete
(@StartDate DATETIME2, 
 @EndDate   DATETIME2
)
RETURNS INT
     BEGIN
         IF(@StartDate IS NULL
            OR @EndDate IS NULL)
             BEGIN
                 RETURN 0;
         END;
         RETURN
         (
             SELECT DATEDIFF(hour, r.OpenDate, r.CloseDate)
             FROM dbo.Reports r
             WHERE r.OpenDate = @StartDate
                   AND r.CloseDate = @EndDate
         );
     END;

GO

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports
GO

--12. Assign Employee
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
