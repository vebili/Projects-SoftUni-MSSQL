CREATE DATABASE Exercise
GO
--1
USE Exercise

CREATE TABLE Persons
(PersonID   INT
 PRIMARY KEY IDENTITY(1, 1), 
 FirstName  VARCHAR(50) NOT NULL, 
 Salary     DECIMAL(15, 2), 
 PassportID INT NOT NULL UNIQUE
);

CREATE TABLE Passports
(PassportID     INT
 PRIMARY KEY IDENTITY(101, 1), 
 PassportNumber VARCHAR(50) NOT null
);

ALTER TABLE dbo.Persons
ADD CONSTRAINT FK_Persons_Passports 
FOREIGN KEY(PassportID) 
REFERENCES Passports(PassportID);

INSERT INTO dbo.Passports(PassportNumber)
VALUES('N34FG21B'), ('K65LO4R7'), ('ZE657QP2');


INSERT INTO dbo.Persons
				(FirstName, Salary, PassportId)
VALUES
				('Roberto', 43300.00, 102), 
				('Tom', 56100.00, 103), 
				('Yana', 60200.00, 101)

GO

--2
USE Exercise

CREATE TABLE Manufacturers
(ManufacturerID INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(20) NOT NULL, 
 EstablishedOn  DATETIME2 NOT NULL
);

CREATE TABLE Models
(ModelID        INT
 PRIMARY KEY IDENTITY(101, 1), 
 [Name]         VARCHAR(20) NOT NULL, 
 ManufacturerID INT NOT NULL
 CONSTRAINT FK_Models_Manifacturers
 FOREIGN KEY (ManufacturerID)
 REFERENCES Manufacturers(ManufacturerID)
);


INSERT INTO dbo.Manufacturers
					([Name], EstablishedOn)
VALUES
					('BMW', '07/03/1916'),
					('Tesla', '01/01/2003'),
					('Lada', '01/05/1966')

INSERT INTO dbo.Models
					([Name], ManufacturerID)
VALUES
					('X1', 1),
					('i6', 1),
					('Model S', 2),
					('Model X', 2),
					('Model 3', 2),
					('Nova', 3)

GO

--3
USE Exercise

CREATE TABLE Students
(StudentID INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(20) NOT NULL
);

CREATE TABLE Exams
(ExamID INT
 PRIMARY KEY IDENTITY(101, 1), 
 [Name]         VARCHAR(20) NOT NULL
);


CREATE TABLE StudentsExams
(StudentID INT NOT NULL, 
 ExamID    INT NOT NULL, 
 CONSTRAINT PK_Students_Exams 
 PRIMARY KEY(StudentID, ExamID), 
 CONSTRAINT FK_StudentsExams_Students 
 FOREIGN KEY(StudentID) 
 REFERENCES Students(StudentID), 
 CONSTRAINT FK_StudentsExams_Exams 
 FOREIGN KEY(ExamID) 
 REFERENCES Exams(ExamID)
);

INSERT INTO dbo.Students([Name])
VALUES('Mila'), ('Toni'), ('Ron');

INSERT INTO dbo.Exams([Name])
VALUES('SpringMVC'), ('Neo4j'), ('Oracle 11g');

INSERT INTO dbo.StudentsExams
				(StudentID, ExamID)
VALUES
				(1, 101),
				(1, 102),
				(2, 101),
				(3, 103),
				(2, 102),
				(2, 103)

GO

--4
CREATE TABLE Teachers
(TeacherID INT
 PRIMARY KEY IDENTITY(101, 1), 
 [Name]         VARCHAR(20) NOT NULL,
 ManagerID INT,
 CONSTRAINT FK_Teachers_Teachers 
 FOREIGN KEY(ManagerID) 
 REFERENCES Teachers(TeacherID)
);

INSERT INTO dbo.Teachers
					([Name], ManagerID)
VALUES
					('John', null),
					('Maya', 106),
					('Silvia', 106),
					('Ted', 105),
					('Mark', 101),
					('Greta', 101)

GO

--5
USE Exercise

CREATE TABLE Cities
(CityID INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(50) NOT NULL
);

CREATE TABLE ItemTypes
(ItemTypeID INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(50) NOT NULL
);

CREATE TABLE Items
(ItemID INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(50) NOT NULL,
 ItemTypeID INT not NULL,
 CONSTRAINT FK_Items_ItemTypes 
 FOREIGN KEY(ItemTypeID) 
 REFERENCES ItemTypes(ItemTypeID)
);

CREATE TABLE Customers
(CustomerID INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(50) NOT NULL,
 CityID INT not NULL,
 CONSTRAINT FK_Customers_Cities 
 FOREIGN KEY(CityID) 
 REFERENCES Cities(CityID)
);

CREATE TABLE Orders
(OrderID INT
 PRIMARY KEY IDENTITY(1, 1), 
 CustomerID INT not NULL,
 CONSTRAINT FK_Orders_Customers 
 FOREIGN KEY(CustomerID) 
 REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems
(OrderID INT NOT NULL, 
 ItemID    INT NOT NULL, 
 CONSTRAINT PK_Orders_Items 
 PRIMARY KEY(OrderID, ItemID), 
 CONSTRAINT FK_OrderItems_Orders 
 FOREIGN KEY(OrderID) 
 REFERENCES Orders(OrderID), 
 CONSTRAINT FK_OrderItems_Items 
 FOREIGN KEY(ItemID) 
 REFERENCES Items(ItemID)
);

GO

--6
CREATE DATABASE Exercise1
GO

USE Exercise1

CREATE TABLE Subjects
(SubjectID INT
 PRIMARY KEY IDENTITY(1, 1), 
 SubjectName         VARCHAR(50) NOT NULL
);

CREATE TABLE Majors
(MajorID INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(50) NOT NULL
);

CREATE TABLE Students
(StudentID INT
 PRIMARY KEY IDENTITY(1, 1), 
 MajorID INT not NULL,
 CONSTRAINT FK_Students_Majors 
 FOREIGN KEY(MajorID) 
 REFERENCES Majors(MajorID),
StudentName VARCHAR(50) NOT NULL,
StudentNumber VARCHAR(50) NOT NULL,
);

CREATE TABLE Payments
(PaymentID INT
 PRIMARY KEY IDENTITY(1, 1), 
 StudentID INT not NULL,
 CONSTRAINT FK_Payments_Students 
 FOREIGN KEY(StudentID) 
 REFERENCES Students(StudentID),
 PaymentDate datetime2 NOT null,
 PaymentAmount decimal(8, 2)
);

CREATE TABLE Agenda
(StudentID INT NOT NULL, 
 SubjectID    INT NOT NULL, 
 CONSTRAINT PK_Students_Subjects 
 PRIMARY KEY(StudentID, SubjectID), 
 CONSTRAINT FK_Agenda_Students 
 FOREIGN KEY(StudentID) 
 REFERENCES Students(StudentID), 
 CONSTRAINT FK_Agenda_Subjects 
 FOREIGN KEY(SubjectID) 
 REFERENCES Subjects(SubjectID)
);

GO

--9
USE [Geography]

SELECT m.MountainRange, p.PeakName, p.Elevation 
    FROM Mountains AS m
    JOIN Peaks As p ON p.MountainId = m.Id
   WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC

GO
