CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns
(Id     INT
			PRIMARY KEY IDENTITY(1, 1), 
 [Name] NVARCHAR(30) NOT NULL
);

CREATE TABLE Addresses
(Id          INT
				PRIMARY KEY IDENTITY(1, 1), 
 AddressText NVARCHAR(50) NOT NULL, 
 TownId      INT 
				FOREIGN KEY REFERENCES Towns(Id) NOT NULL
);

CREATE TABLE Departments
(Id     INT
			PRIMARY KEY IDENTITY(1, 1), 
 [Name] NVARCHAR(30) NOT NULL
);

CREATE TABLE Employees
(Id           INT
					PRIMARY KEY IDENTITY(1, 1), 
 FirstName    NVARCHAR(30) NOT NULL, 
 MiddleName   NVARCHAR(30), 
 LastName     NVARCHAR(30) NOT NULL, 
 JobTitle     NVARCHAR(20) NOT NULL, 
 DepartmentId INT 
					FOREIGN KEY REFERENCES Departments(Id), 
 HireDate     DATETIME2, 
 Salary       DECIMAL(8, 2) NOT NULL, 
 AddressId    INT 
					FOREIGN KEY REFERENCES Addresses(Id)
);


GO

BACKUP DATABASE SoftUni TO DISK='D:\Proba\Exercises\softuni-backup.bak'

DROP DATABASE SoftUni

RESTORE DATABASE SoftUni FROM DISK='D:\Proba\Exercises\softuni-backup.bak'

GO

USE SoftUni

INSERT INTO Towns 
				([Name])
VALUES 
				('Sofia'),
				('Plovdiv'),
				('Varna'),
				('Burgas')

INSERT INTO Departments 
					([Name])
VALUES 
					('Engineering'),
					('Sales'),
					('Marketing'),
					('Software Development'),
					('Quality Assurance')

INSERT INTO Employees 
					(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
VALUES 
					('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500),
					('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000),
					('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
					('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2007-12-09', 5000),
					('Peter', 'Dimitrov', 'Georgiev', 'Intern', 3, '2016-08-28', 599.88)


GO



USE SoftUni

SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees

GO



USE SoftUni

SELECT * FROM Towns
ORDER BY [Name] ASC

SELECT * FROM Departments
ORDER BY [Name] ASC

SELECT * FROM Employees
ORDER BY Salary DESC;

GO



USE SoftUni

SELECT [Name] FROM Towns
ORDER BY [Name] ASC

SELECT [Name] FROM Departments
ORDER BY [Name] ASC

SELECT FirstName, LastName, JobTitle, Salary FROM Employees
ORDER BY Salary DESC;

GO


USE SoftUni

UPDATE Employees
SET Salary *= 1.1

SELECT Salary FROM Employees
