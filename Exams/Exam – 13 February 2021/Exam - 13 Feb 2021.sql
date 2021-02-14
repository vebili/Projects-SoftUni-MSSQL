--1
--CREATE DATABASE Bitbucket
USE Bitbucket

CREATE TABLE Users
(
 Id INT PRIMARY KEY IDENTITY, 
 Username   VARCHAR(30) NOT NULL, 
 [Password] VARCHAR(30) NOT NULL, 
 Email      VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
 Id INT PRIMARY KEY IDENTITY, 
 [Name]   VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
 RepositoryId  INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id), 
 ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id), 
 PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
 Id INT PRIMARY KEY IDENTITY, 
 Title        VARCHAR(255) NOT NULL, 
 IssueStatus  CHAR(6) NOT NULL, 
 RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id), 
 AssigneeId   INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Commits
(
 Id INT PRIMARY KEY IDENTITY, 
 [Message]     VARCHAR(255) NOT NULL, 
 IssueId       INT FOREIGN KEY REFERENCES Issues(Id), 
 RepositoryId  INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id), 
 ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Files
(
Id INT PRIMARY KEY IDENTITY, 
 [Name]   VARCHAR(100) NOT NULL, 
 Size     DECIMAL(18, 2) NOT NULL, 
 ParentId INT FOREIGN KEY REFERENCES Files(Id), 
 CommitId INT NOT NULL FOREIGN KEY REFERENCES Commits(Id)
)


--2
USE Bitbucket
GO

INSERT INTO Files
([Name], Size, ParentId, CommitId) VALUES
('Trade.idk', 2598.0, 1, 1 ),
('menu.net', 9238.31, 2, 2 ),
('Administrate.soshy', 1246.93, 3, 3 ),
('Controller.php', 7353.15, 4, 4 ),
('Find.java', 9957.86, 5, 5 ),
('Controller.json', 14034.87, 3, 6 ),
('Operate.xix', 7662.92, 7, 7 )

INSERT INTO Issues
(Title, IssueStatus, RepositoryId, AssigneeId) VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)

GO

--3
USE Bitbucket
GO

UPDATE Issues SET Issues.IssueStatus = ''
WHERE Issues.AssigneeId = 6

GO

--4
USE Bitbucket
GO

DECLARE @repositoryId INT=
(
    SELECT r.Id
    FROM Repositories r
    WHERE r.Name = 'Softuni-Teamwork'
)

DELETE FROM RepositoriesContributors
WHERE RepositoriesContributors.RepositoryId = 3

DELETE FROM Issues
WHERE Issues.RepositoryId = 3

GO

--5
USE Bitbucket
GO

SELECT c.Id, 
       c.[Message], 
       c.RepositoryId, 
       c.ContributorId
FROM Commits c
ORDER BY c.Id, 
         c.[Message], 
         c.RepositoryId, 
         c.ContributorId

GO

--6
USE Bitbucket
GO

SELECT f.Id, f.[Name], f.Size
FROM Files f
WHERE f.Size > 1000 AND f.[Name] LIKE '%html%'
ORDER BY f.Size DESC, f.Id, f.[Name]

GO

--7
USE Bitbucket
GO

SELECT i.Id, concat(u.Username, ' : ', i.Title) IssueAssignee
FROM Issues i
JOIN Users u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, u.Username

GO

--8
USE Bitbucket
GO

SELECT f.Id, f.[Name], Concat(f.Size, 'KB') Size
FROM Files f
WHERE f.id NOT IN
(
    SELECT f.ParentId
    FROM Files f
         LEFT JOIN Files f2 ON f.ParentId = f2.Id
    WHERE f.ParentId IS NOT NULL
)
ORDER BY f.Id, f.[Name], Size

GO

--9!!!!!!!!
USE Bitbucket
GO

SELECT TOP (5) r.Id, r.[Name], COUNT(c.Id) Commits
FROM Repositories r
     JOIN Commits c ON r.Id = c.RepositoryId
     JOIN RepositoriesContributors rc ON r.Id = rc.RepositoryId
GROUP BY r.Id, r.[Name]
ORDER BY Commits DESC, r.Id, r.[Name]

-- One repository has many commits with CommitContibutor and has many
-- RepositoriesContributors. So we have to find the combination of them, 
-- not only relation between repository and commit.
/*
SELECT r.Id RepID, 
       r.[Name], 
       c.RepositoryId, 
       c.Id commitID, 
       c.ContributorId CommitsContributorId, 
       rc.ContributorId RepositoriesContributorsId
FROM Commits c
     JOIN Repositories r ON r.Id = c.RepositoryId
     JOIN RepositoriesContributors rc ON r.Id = rc.RepositoryId
ORDER BY RepID;
*/

GO

--10
USE Bitbucket
GO

SELECT u.Username, AVG(f.Size) Size
FROM Users u
JOIN Commits c ON u.Id = c.ContributorId
JOIN Files f ON c.Id = f.CommitId
GROUP BY u.Username
ORDER BY AVG(f.Size) DESC, u.Username ASC

GO

--11
USE Bitbucket
GO

CREATE FUNCTION dbo.udf_AllUserCommits(@username VARCHAR(50))
RETURNS INT
     BEGIN
         DECLARE @countCommits INT=
         (
             SELECT Count(*)
             FROM Users u
                  JOIN Commits c ON u.Id = c.ContributorId
             WHERE u.Username = @username
         )
         RETURN @countCommits
     END

SELECT dbo.udf_AllUserCommits('UnderSinduxrein')
GO

--12
USE Bitbucket
GO

CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
SELECT f.Id, f.Name, Concat(f.Size, 'KB') Size
     FROM Files f
     WHERE f.Name LIKE '%.' + @fileExtension
     ORDER BY f.Id ASC, f.Name ASC, Size DESC
GO

EXEC usp_SearchForFiles 'txt'