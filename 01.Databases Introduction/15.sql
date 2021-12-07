CREATE DATABASE Hotel;

USE Hotel;


CREATE TABLE Employees
(Id        INT
				PRIMARY KEY IDENTITY, 
 FirstName NVARCHAR(30) NOT NULL, 
 LastName  NVARCHAR(30) NOT NULL, 
 Title     NVARCHAR(20) NOT NULL, 
 Notes     NVARCHAR(MAX)
);

CREATE TABLE Customers
(AccountNumber   INT
					PRIMARY KEY, 
 FirstName       NVARCHAR(30) NOT NULL, 
 LastName        NVARCHAR(30) NOT NULL, 
 PhoneNumber     NVARCHAR(20), 
 EmergencyName   NVARCHAR(30), 
 EmergencyNumber NVARCHAR(20), 
 Notes           NVARCHAR(MAX)
);

CREATE TABLE RoomStatus
(RoomStatus NVARCHAR(10)
				PRIMARY KEY, 
 Notes      NVARCHAR(MAX),
);

CREATE TABLE RoomTypes
(RoomType NVARCHAR(10)
				PRIMARY KEY, 
 Notes    NVARCHAR(MAX),
);

CREATE TABLE BedTypes
(BedType NVARCHAR(10)
				PRIMARY KEY, 
 Notes   NVARCHAR(MAX),
);

CREATE TABLE Rooms
(RoomNumber INT
				PRIMARY KEY IDENTITY, 
 RoomType   NVARCHAR(10) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL, 
 BedType    NVARCHAR(10) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL, 
 Rate       DECIMAL(8, 2) NOT NULL, 
 RoomStatus NVARCHAR(10) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL, 
 Notes      NVARCHAR(MAX)
);

CREATE TABLE Payments
(Id                INT
						PRIMARY KEY IDENTITY, 
 EmployeeId        INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
 PaymentDate       DATETIME2 NOT NULL, 
 AccountNumber     INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL, 
 FirstDateOccupied DATETIME2 NOT NULL, 
 LastDateOccupied  DATETIME2 NOT NULL, 
 TotalDays		   AS DATEDIFF(day, FirstDateOccupied, LastDateOccupied), 
 AmountCharged     DECIMAL(8, 2) NOT NULL, 
 TaxRate           DECIMAL(5, 2) NOT NULL, 
 TaxAmount		   AS AmountCharged * TaxRate, 
 PaymentTotal      AS AmountCharged + (AmountCharged * TaxRate), 
 Notes             NVARCHAR(MAX)
);

CREATE TABLE Occupancies
(Id            INT
					PRIMARY KEY IDENTITY, 
 EmployeeId    INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
 DateOccupied  DATETIME2 NOT NULL, 
 AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL, 
 RoomNumber    INT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL, 
 RateApplied   DECIMAL(8, 2) NOT NULL, 
 PhoneCharge   DECIMAL(8, 2), 
 Notes         NVARCHAR(MAX)
);


INSERT INTO Employees 
				(FirstName, LastName, Title) 
VALUES
				('Ivan', 'Ivanov', 'Driver'),
				('Petar', 'Petrov', 'Menager'),
				('Ana', 'Aneva', 'Maid')

INSERT INTO Customers 
				(AccountNumber, FirstName, LastName)
VALUES 
				(1123, 'George', 'Gergiev'),
				(2346, 'Atanas', 'Atanasov'),
				(4798, 'Ivaylo', 'Peev')

INSERT INTO RoomStatus 
				(RoomStatus) 
VALUES 
				('Empty'),
				('Occupied'),
				('Reserved')

INSERT INTO RoomTypes 
				(RoomType)
VALUES 
				('Single'),
			    ('Double'),
		        ('Apartment')

INSERT INTO BedTypes 
				(BedType)
VALUES 
				('Single'),
		        ('King size'),
		        ('Queen size')

INSERT INTO Rooms 
				(RoomType, BedType, Rate, RoomStatus)
VALUES 
				('Single', 'Single', 80, 'Empty'),
	            ('Double', 'Queen size', 120, 'Occupied'),
	            ('Apartment', 'King size', 160, 'Reserved')

INSERT INTO Payments
				(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, AmountCharged, TaxRate)
VALUES 
				(1, '2018-07-10', 1123, '2018-06-18', '2018-06-25', 1256.33, 0.10),
				(2, '2019-04-10', 2346, '2019-03-15', '2019-03-20', 556, 0.15),
				(3, '2019-09-10', 4798, '2019-07-25', '2019-08-10', 146.74, 0.20)

INSERT INTO Occupancies 
				(EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied)
VALUES 
				(1, '2018-07-10', 1123, 1, 50),
				(2, '2019-04-10', 2346, 2, 80),
				(3, '2019-09-10', 4798, 3, 100)
