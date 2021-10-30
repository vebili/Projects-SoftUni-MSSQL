--CREATE DATABASE ColonialJourney 
--USE ColonialJourney
--1

CREATE TABLE Planets
(Id     INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name] VARCHAR(30) NOT NULL
);
CREATE TABLE Spaceports
(Id       INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]   VARCHAR(50) NOT NULL, 
 PlanetId INT NOT NULL
              CHECK(PlanetId >= 1)
              FOREIGN KEY REFERENCES dbo.Planets(Id)
);
CREATE TABLE Spaceships
(Id             INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]         VARCHAR(50) NOT NULL, 
 Manufacturer   VARCHAR(30) NOT NULL, 
 LightSpeedRate INT DEFAULT 0
                    CHECK(LightSpeedRate >= 0)
);
CREATE TABLE Colonists
(Id        INT
 PRIMARY KEY IDENTITY(1, 1), 
 FirstName VARCHAR(20) NOT NULL, 
 LastName  VARCHAR(20) NOT NULL, 
 Ucn       VARCHAR(10) NOT NULL UNIQUE, 
 BirthDate DATETIME2 NOT NULL
);
CREATE TABLE Journeys
(Id                     INT
 PRIMARY KEY IDENTITY(1, 1), 
 JourneyStart           DATETIME2 NOT NULL, 
 JourneyEnd             DATETIME2 NOT NULL, 
 Purpose                VARCHAR(11) CHECK(Purpose IN('Medical', 'Technical', 'Educational', 'Military')), 
 DestinationSpaceportId INT NOT NULL
                            CHECK(DestinationSpaceportId >= 0)
                            FOREIGN KEY REFERENCES Spaceports(Id), 
 SpaceshipId            INT NOT NULL
                            CHECK(SpaceshipId >= 0)
                            FOREIGN KEY REFERENCES Spaceships(Id)
);
CREATE TABLE TravelCards
(Id               INT
 PRIMARY KEY IDENTITY(1, 1), 
 CardNumber       CHAR(10) NOT NULL UNIQUE, 
 JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')), 
 ColonistId       INT NOT NULL
                      CHECK(ColonistId >= 0)
                      FOREIGN KEY REFERENCES Colonists(Id), 
 JourneyId        INT NOT NULL
                      CHECK(JourneyId >= 0)
                      FOREIGN KEY REFERENCES Journeys(Id)
);

GO

--2
INSERT INTO dbo.Planets
				(Name)
VALUES
				('Mars'),
				('Earth'),
				('Jupiter'),
				('Saturn')

INSERT INTO dbo.Spaceships
				(Name, Manufacturer, LightSpeedRate)
VALUES
				('Golf', 'VW', 3),
				('WakaWaka', 'Wakanda', 4),
				('Falcon9', 'SpaceX', 1),
				('Bed', 'Vidolov', 6)
GO

--3
UPDATE dbo.Spaceships
  SET 
      dbo.Spaceships.LightSpeedRate += 1
WHERE dbo.Spaceships.Id BETWEEN 8 AND 12;
GO

--4
DELETE FROM dbo.TravelCards
WHERE dbo.TravelCards.JourneyId BETWEEN 1 AND 3;
DELETE FROM dbo.Journeys
WHERE dbo.Journeys.Id BETWEEN 1 AND 3;
GO

--5
SELECT tc.CardNumber, 
       tc.JobDuringJourney
FROM dbo.TravelCards tc
ORDER BY tc.CardNumber;
GO

--6
SELECT c.Id, 
       concat(c.FirstName, ' ', c.LastName) FullName, 
       c.Ucn
FROM dbo.Colonists c
ORDER BY c.FirstName, 
         c.LastName, 
         c.Id;
GO

--7
SELECT j.Id, 
       format(j.JourneyStart, 'dd/MM/yyyy') JourneyStart, 
       format(j.JourneyEnd, 'dd/MM/yyyy') JourneyEnd
FROM dbo.Journeys j
WHERE j.Purpose = 'Military'
ORDER BY j.JourneyStart;
GO
 
--8
SELECT c.Id, 
       CONCAT(c.FirstName, ' ', c.LastName) full_name
FROM dbo.Colonists c
     JOIN dbo.TravelCards tc ON c.Id = tc.ColonistId
WHERE tc.JobDuringJourney = 'Pilot'
ORDER BY c.Id;
GO

--9
SELECT Count(tc.ColonistId)
FROM dbo.TravelCards tc 
	 JOIN dbo.Journeys j ON tc.JourneyId = j.Id
WHERE j.Purpose = 'technical';
GO

--10
SELECT TOP (1) s.Name SpaceshipName, 
               s2.Name SpaceportName
FROM dbo.Spaceships s
     JOIN dbo.Journeys j ON s.Id = j.SpaceshipId
     JOIN dbo.Spaceports s2 ON j.DestinationSpaceportId = s2.Id
ORDER BY s.LightSpeedRate DESC;

--11
SELECT DISTINCT s.Name, s.Manufacturer
FROM dbo.Spaceships s
     JOIN dbo.Journeys j ON s.Id = j.SpaceshipId
     JOIN dbo.TravelCards tc ON j.Id = tc.JourneyId
     JOIN dbo.Colonists c ON tc.ColonistId = c.Id
WHERE c.BirthDate > '01/01/1989' AND tc.JobDuringJourney = 'Pilot'
ORDER BY s.Name;
GO

--12
SELECT p.Name PlanetName, 
       s.Name SpaceportName
FROM dbo.Planets p
     JOIN dbo.Spaceports s ON p.Id = s.PlanetId
     JOIN dbo.Journeys j ON s.Id = j.DestinationSpaceportId
WHERE j.Purpose = 'educational'
ORDER BY SpaceportName DESC;
GO

--13
SELECT p.Name PlanetName, 
       COUNT(j.Id) JourneysCount
FROM dbo.Planets p
     JOIN dbo.Spaceports s ON p.Id = s.PlanetId
     JOIN dbo.Journeys j ON s.Id = j.DestinationSpaceportId
GROUP BY p.Name
ORDER BY JourneysCount DESC, 
         PlanetName;
GO

--14
SELECT TOP (1) j.Id, 
               p.Name PlanetName, 
               s.Name SpaceportName, 
               j.Purpose JourneyPurpose
FROM dbo.Journeys j
     JOIN dbo.Spaceports s ON j.DestinationSpaceportId = s.Id
     JOIN dbo.Planets p ON s.PlanetId = p.Id
ORDER BY DATEDIFF(day, j.JourneyStart, j.JourneyEnd);
GO

--15
SELECT TOP (1) j.Id JourneyId, 
               tc.JobDuringJourney JobName
FROM dbo.Journeys j
     JOIN dbo.TravelCards tc ON j.Id = tc.JourneyId
GROUP BY tc.JobDuringJourney, 
         j.Id, 
         j.JourneyStart, 
         j.JourneyEnd
ORDER BY DATEDIFF(second, j.JourneyStart, j.JourneyEnd) DESC, 
         COUNT(tc.ColonistId);
GO

--16
WITH CTE_JobRanking AS (SELECT tc.JobDuringJourney JobDuringJourney, 
       CONCAT(c.FirstName, ' ', c.LastName) FullName, 
       DENSE_RANK() OVER(PARTITION BY tc.JobDuringJourney
       ORDER BY c.BirthDate) JobRank
FROM dbo.Colonists c
     JOIN dbo.TravelCards tc ON c.Id = tc.ColonistId)

SELECT JobDuringJourney, 
       FullName, 
       JobRank
FROM CTE_JobRanking
WHERE CTE_JobRanking.JobRank = 2;
GO

--17
SELECT p.Name [Name], 
       COUNT(s.Id) [Count]
FROM dbo.Planets p
     LEFT JOIN dbo.Spaceports s ON p.Id = s.PlanetId
GROUP BY p.Name
ORDER BY [Count] DESC, 
         [Name];
GO

--18
CREATE FUNCTION dbo.udf_GetColonistsCount
(@PlanetName VARCHAR(30)
)
RETURNS INT
     BEGIN
         DECLARE @count INT=
         (
             SELECT COUNT(tc.ColonistId)
             FROM dbo.Planets p
                  JOIN dbo.Spaceports s ON p.Id = s.PlanetId
                  JOIN dbo.Journeys j ON s.Id = j.DestinationSpaceportId
                  JOIN dbo.TravelCards tc ON j.Id = tc.JourneyId
             WHERE p.Name = @PlanetName
         );
         RETURN @count;
     END;
GO

SELECT dbo.udf_GetColonistsCount('Otroyphus')
GO

--19
CREATE PROC usp_ChangeJourneyPurpose
(@JourneyId  INT, 
 @NewPurpose VARCHAR(11)
)
AS
     DECLARE @journeyOldPurpose VARCHAR(11)=
     (
         SELECT j.Purpose
         FROM dbo.Journeys j
         WHERE j.Id = @JourneyId
     );
     IF(@journeyOldPurpose IS NULL)
         BEGIN
             RAISERROR('The journey does not exist!', 16, 1);
     END;
     IF(@journeyOldPurpose = @NewPurpose)
         BEGIN
             RAISERROR('You cannot change the purpose!', 16, 1);
     END;
     UPDATE dbo.Journeys
       SET 
           dbo.Journeys.Purpose = @NewPurpose
     WHERE dbo.Journeys.Id = @JourneyId;
GO
EXEC usp_ChangeJourneyPurpose 1, 'Technical'
SELECT * FROM Journeys
EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'
GO

--20
CREATE TABLE DeletedJourneys(
Id int, 
JourneyStart datetime2, 
JourneyEnd datetime2, 
Purpose varchar(11), 
DestinationSpaceportId int, 
SpaceshipId int
)
GO

CREATE TRIGGER tr_DeleteJourney ON dbo.Journeys
FOR DELETE
AS
     INSERT INTO DeletedJourneys
            SELECT *
            FROM DELETED d;
GO