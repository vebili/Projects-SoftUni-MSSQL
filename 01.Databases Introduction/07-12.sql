CREATE  DATABASE MINIONS

USE MINIONS

CREATE TABLE People (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height DECIMAL(3, 2),
	[Weight] DECIMAL(5, 2),
	Gender CHAR(1) NOT NULL CHECK (Gender IN ('m', 'f')),
	Birthdate DATETIME2 NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People
			([Name], Gender, Birthdate)
VALUES  
			('AAAAA', 'm', '19990305'),
			('bbbb', 'm', '19861210'),
			('NNNN', 'f', '19750509'),
			('CCCC', 'm', '20000505'),
			('TTTT', 'f', '19810306')

GO

CREATE TABLE Users (
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX) CHECK (DATALENGTH(ProfilePicture) <= 912600),
	LastLoginTime DATETIME2,
	IsDeleted VARCHAR(5) NOT NULL CHECK (IsDeleted IN ('true', 'false'))
)

INSERT INTO Users
			(Username, [Password], IsDeleted)
VALUES  
			('AAAAA', '123456', 'true'),
			('bbbb', '123456', 'false'),
			('NNNN', '123456', 'true'),
			('CCCC', '123456', 'false'),
			('TTTT', '123456', 'true')

GO

ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07C83EB49F

ALTER TABLE Users
ADD CONSTRAINT PK_IdUsername
PRIMARY KEY (Id, Username)

GO

ALTER TABLE Users
ADD CONSTRAINT CK_PasswordLength
CHECK (LEN([Password]) >= 5)

GO


ALTER TABLE Users
ADD DEFAULT GETDATE()
FOR LastLoginTime

GO


ALTER TABLE Users
DROP CONSTRAINT PK_IdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Id
PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CK_Username
CHECK (LEN(Username) >= 3)
