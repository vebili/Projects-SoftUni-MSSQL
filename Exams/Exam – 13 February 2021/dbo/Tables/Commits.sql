﻿CREATE TABLE Commits
(
 Id INT PRIMARY KEY IDENTITY, 
 [Message]     VARCHAR(255) NOT NULL, 
 IssueId       INT FOREIGN KEY REFERENCES Issues(Id), 
 RepositoryId  INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id), 
 ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)