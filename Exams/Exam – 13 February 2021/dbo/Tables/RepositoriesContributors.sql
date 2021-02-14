CREATE TABLE RepositoriesContributors
(
 RepositoryId  INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id), 
 ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id), 
 PRIMARY KEY(RepositoryId, ContributorId)
)