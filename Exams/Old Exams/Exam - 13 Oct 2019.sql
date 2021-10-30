--1
--CREATE DATABASE Bitbucket

USE Bitbucket

CREATE TABLE Users
(Id         INT
 PRIMARY KEY IDENTITY(1, 1), 
 Username   VARCHAR(30) NOT NULL, 
 [Password] VARCHAR(30) NOT NULL, 
 Email      VARCHAR(50) NOT NULL
);

CREATE TABLE Repositories
(Id         INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]   VARCHAR(50) NOT NULL
);

CREATE TABLE RepositoriesContributors
(RepositoryId  INT NOT NULL
                   FOREIGN KEY REFERENCES dbo.Repositories(Id), 
 ContributorId INT NOT NULL
                   FOREIGN KEY REFERENCES dbo.Users(Id), 
 PRIMARY KEY(RepositoryId, ContributorId)
);

CREATE TABLE Issues
(Id           INT
 PRIMARY KEY IDENTITY(1, 1), 
 Title        VARCHAR(255) NOT NULL, 
 IssueStatus  CHAR(6) NOT NULL, 
 RepositoryId INT NOT NULL
                  FOREIGN KEY REFERENCES dbo.Repositories(Id), 
 AssigneeId   INT NOT NULL
                  FOREIGN KEY REFERENCES dbo.Users(Id)
);

CREATE TABLE Commits
(Id            INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Message]     VARCHAR(255) NOT NULL, 
 IssueId       INT FOREIGN KEY REFERENCES dbo.Issues(Id), 
 RepositoryId  INT NOT NULL
                   FOREIGN KEY REFERENCES dbo.Repositories(Id), 
 ContributorId INT NOT NULL
                   FOREIGN KEY REFERENCES dbo.Users(Id)
);

CREATE TABLE Files
(Id       INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]   VARCHAR(100) NOT NULL, 
 Size     DECIMAL(18, 2) NOT NULL, 
 ParentId INT FOREIGN KEY REFERENCES Files(Id), 
 CommitId INT NOT NULL
              FOREIGN KEY REFERENCES Commits(Id)
);

GO

--2
USE Bitbucket
GO

INSERT INTO dbo.Files
				([Name], Size, ParentId, CommitId)
VALUES
				('Trade.idk', 2598.0, 1, 1 ),
				('menu.net', 9238.31, 2, 2 ),
				('Administrate.soshy', 1246.93, 3, 3 ),
				('Controller.php', 7353.15, 4, 4 ),
				('Find.java', 9957.86, 5, 5 ),
				('Controller.json', 14034.87, 3, 6 ),
				('Operate.xix', 7662.92, 7, 7 );

INSERT INTO dbo.Issues
				(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES
				('Critical Problem with HomeController.cs file', 'open', 1, 4),
				('Typo fix in Judge.html', 'open', 4, 3),
				('Implement documentation for UsersService.cs', 'closed', 8, 2),
				('Unreachable code in Index.cs', 'open', 9, 8);

GO

--3
USE Bitbucket
GO

UPDATE dbo.Issues
  SET 
      dbo.Issues.IssueStatus = ''
WHERE dbo.Issues.AssigneeId = 6;

GO

--4
USE Bitbucket
GO

DECLARE @repositoryId INT=
(
    SELECT r.Id
    FROM dbo.Repositories r
    WHERE r.Name = 'Softuni-Teamwork'
);

DELETE FROM dbo.RepositoriesContributors
WHERE dbo.RepositoriesContributors.RepositoryId = @repositoryId

DELETE FROM dbo.Issues
WHERE dbo.Issues.RepositoryId = @repositoryId

GO

--5
USE Bitbucket
GO

SELECT c.Id, 
       c.[Message], 
       c.RepositoryId, 
       c.ContributorId
FROM dbo.Commits c
ORDER BY c.Id, 
         c.[Message], 
         c.RepositoryId, 
         c.ContributorId;

GO

--6
USE Bitbucket
GO

SELECT f.Id, 
       f.[Name], 
       f.Size
FROM dbo.Files f
WHERE f.Size > 1000
      AND f.[Name] LIKE '%html%'
ORDER BY f.Size DESC, 
         f.Id, 
         f.[Name];

GO

--7
USE Bitbucket
GO

SELECT i.Id, 
       concat(u.Username, ' : ', i.Title) IssueAssignee
FROM dbo.Issues i
     JOIN dbo.Users u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, 
         u.Username;

GO

--8
USE Bitbucket
GO

SELECT f.Id, 
       f.[Name], 
       Concat(f.Size, 'KB') Size
FROM dbo.Files f
WHERE f.id NOT IN
(
    SELECT f.ParentId
    FROM dbo.Files f
         LEFT JOIN dbo.Files f2 ON f.ParentId = f2.Id
    WHERE f.ParentId IS NOT NULL
)
ORDER BY f.Id, 
         f.[Name], 
         Size;

GO

--9!!!!!!!!
USE Bitbucket
GO

SELECT TOP (5) r.Id, 
               r.[Name], 
               COUNT(c.Id) Commits
FROM dbo.Repositories r
     JOIN dbo.Commits c ON r.Id = c.RepositoryId
     JOIN dbo.RepositoriesContributors rc ON r.Id = rc.RepositoryId
GROUP BY r.Id, 
         r.[Name]
ORDER BY Commits DESC, 
         r.Id, 
         r.[Name];

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
FROM dbo.Commits c
     JOIN dbo.Repositories r ON r.Id = c.RepositoryId
     JOIN dbo.RepositoriesContributors rc ON r.Id = rc.RepositoryId
ORDER BY RepID;
*/

GO

--10
USE Bitbucket
GO

SELECT u.Username, 
       AVG(f.Size) Size
FROM dbo.Users u
     JOIN dbo.Commits c ON u.Id = c.ContributorId
     JOIN dbo.Files f ON c.Id = f.CommitId
GROUP BY u.Username
ORDER BY AVG(f.Size) DESC, u.Username;

GO

--11
USE Bitbucket
GO

CREATE FUNCTION udf_UserTotalCommits
(@username VARCHAR(50)
)
RETURNS INT
     BEGIN
         DECLARE @countCommits INT=
         (
             SELECT Count(*)
             FROM dbo.Users u
                  JOIN dbo.Commits c ON u.Id = c.ContributorId
             WHERE u.Username = @username
         );
         RETURN @countCommits;
     END;
GO

SELECT dbo.udf_UserTotalCommits('UnderSinduxrein')

GO

--12
USE Bitbucket
GO

CREATE PROC usp_FindByExtension(@extension VARCHAR(10))
AS
     SELECT f.Id, 
            f.[Name], 
            Concat(f.Size, 'KB') Size
     FROM dbo.Files f
     WHERE f.[Name] LIKE '%.' + @extension
     ORDER BY f.Id, 
              f.[Name], 
              Size;

GO

EXEC usp_FindByExtension 'txt'