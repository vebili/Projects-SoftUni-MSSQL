CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors
(Id           INT
				PRIMARY KEY IDENTITY, 
 DirectorName NVARCHAR(50) NOT NULL, 
 Notes        NTEXT
);

CREATE TABLE Genres
(Id        INT
					PRIMARY KEY IDENTITY, 
 GenreName NVARCHAR(50) NOT NULL, 
 Notes     NTEXT
);

CREATE TABLE Categories 
(Id           INT
					PRIMARY KEY IDENTITY, 
 CategoryName NVARCHAR(50) NOT NULL, 
 Notes        NTEXT
)

CREATE TABLE Movies
(Id            INT
				   PRIMARY KEY IDENTITY, 
 Title         NVARCHAR(20) NOT NULL, 
 DirectorId    INT NOT NULL
                   FOREIGN KEY REFERENCES Directors(Id), 
 CopyrightYear DATETIME2, 
 [Length]      INT, 
 GenreId       INT NOT NULL
                   FOREIGN KEY REFERENCES Genres(Id), 
 CategoryId    INT NOT NULL
                   FOREIGN KEY REFERENCES Categories(Id), 
 Rating        INT, 
 Notes         NTEXT
);

INSERT INTO		Directors
				(DirectorName)
VALUES
				('Ivan Ivanov'),
				('Petar Petrov'),
				('Georgy Georgiev'),
				('Ana Aneva'),
				('Ina Tosheva')


INSERT INTO		Genres
				(GenreName)
VALUES
				('action'),
				('comedy'),
				('thriller'),
				('documentary'),
				('animation')


INSERT INTO		Categories
				(CategoryName)
VALUES
				('0'),
				('8'),
				('12'),
				('16'),
				('18')



INSERT INTO		Movies
				(Title, DirectorId, GenreId, CategoryId)
VALUES
				('AAAAAA', 2, 3, 5),
				('BBBBBB', 1, 4, 2),
				('CCCCCC', 3, 2, 4),
				('DDDDDD', 5, 1, 3),
				('EEEEEE', 4, 5, 1)
