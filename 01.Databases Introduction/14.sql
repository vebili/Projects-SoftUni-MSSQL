CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories
(Id           INT
				PRIMARY KEY IDENTITY, 
 CategoryName NVARCHAR(20) NOT NULL, 
 DailyRate    DECIMAL(7, 2), 
 WeeklyRate   DECIMAL(7, 2), 
 MonthlyRate  DECIMAL(7, 2), 
 WeekendRate  DECIMAL(7, 2),
);

CREATE TABLE Cars
(Id           INT
				PRIMARY KEY IDENTITY, 
 PlateNumber  VARCHAR(6) NOT NULL, 
 Manifacturer VARCHAR(20), 
 Model        VARCHAR(20), 
 CarYear      DATETIME2, 
 CategoryId   INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL, 
 Doors        INT, 
 Picture      VARBINARY(MAX) CHECK(DATALENGTH(Picture) <= 1050000), 
 Condition	  NVARCHAR(20), 
 Available    BIT NOT NULL
);

CREATE TABLE Employees
(Id        INT
				PRIMARY KEY IDENTITY, 
 FirstName NVARCHAR(30) NOT NULL, 
 LastName  NVARCHAR(30) NOT NULL, 
 Title     NVARCHAR(20) NOT NULL, 
 Notes     NVARCHAR(MAX)
);

CREATE TABLE Customers
(Id                  INT
						PRIMARY KEY IDENTITY, 
 DriverLicenceNumber VARCHAR(15) NOT NULL, 
 FullName            NVARCHAR(50) NOT NULL, 
 [Address]           NVARCHAR(80), 
 City                NVARCHAR(20), 
 ZIPCode             INT, 
 Notes               NVARCHAR(MAX)
);

CREATE TABLE RentalOrders
(Id               INT
					PRIMARY KEY IDENTITY, 
 EmployeeId       INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
 CustomerId       INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL, 
 CarId            INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL, 
 TankLevel        DECIMAL(5, 2), 
 KilometrageStart INT NOT NULL, 
 KilometrageEnd   INT NOT NULL, 
 TotalKilometrage AS KilometrageEnd - KilometrageStart, 
 StartDate        DATETIME2, 
 EndDate          DATETIME2, 
 TotalDays		  AS DATEDIFF(day, StartDate, EndDate), 
 RateApplied      DECIMAL(7, 2), 
 TaxRate          DECIMAL(7, 2), 
 OrderStatus      NVARCHAR(20), 
 Notes            NVARCHAR(MAX)
);


INSERT INTO Categories 
				(CategoryName) 
VALUES 
				('Car'),
				('Bus'),
				('Truck')

INSERT INTO Cars 
				(PlateNumber, CategoryId, Available) 
VALUES 
				('111111', 1, 1),
				('222222', 2, 1),
				('333333', 3, 0)

INSERT INTO Employees 
					(FirstName, LastName, Title) 
VALUES 
					('Ivan', 'Ivanov', 'Seller'),
					('Petar', 'Petrov', 'Maintenance'),
					('George', 'Georgiev', 'Manager')

INSERT INTO Customers 
					(DriverLicenceNumber, FullName)
VALUES 
					(1111111111, 'AAA AAA'),
					(2222222222, 'BBB BBB'),
					(3333333333, 'CCC CCC')

INSERT INTO RentalOrders (EmployeeId, CustomerId, CarId, KilometrageStart, KilometrageEnd) 
       VALUES (1, 1, 1, 1000, 2000),
              (2, 2, 2, 5000, 7000),
              (3, 3, 3, 20000, 25000)

