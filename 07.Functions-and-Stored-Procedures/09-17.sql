--09
USE Bank
GO

CREATE TABLE Logs(
LogId int PRIMARY KEY IDENTITY(1, 1), 
AccountId int NOT NULL FOREIGN KEY REFERENCES Accounts(Id), 
OldSum money, 
NewSum money
)
GO

CREATE TRIGGER tr_AccountsInsert ON dbo.Accounts
FOR UPDATE
AS
     DECLARE @newSum MONEY=
     (
         SELECT i.Balance
         FROM INSERTED i
     );
     DECLARE @oldSum MONEY=
     (
         SELECT d.Balance
         FROM DELETED d
     );
     DECLARE @accountID INT=
     (
         SELECT i.Id
         FROM INSERTED i
     );
     INSERT INTO dbo.Logs
     (AccountId, 
      OldSum, 
      NewSum
     )
     VALUES
     (@accountID, 
      @oldSum, 
      @newSum
     );

GO

--10
USE Bank
GO

CREATE TABLE NotificationEmails(
Id int PRIMARY KEY IDENTITY(1, 1), 
Recipient int FOREIGN KEY REFERENCES dbo.Accounts(Id), 
[Subject] nvarchar(100), 
Body nvarchar(MAX)
)
GO

CREATE TRIGGER tr_LogsEmail ON dbo.Logs
FOR INSERT
AS
     DECLARE @newSum MONEY=
     (
         SELECT i.NewSum
         FROM INSERTED i
     );
     DECLARE @oldSum MONEY=
     (
         SELECT d.OldSum
         FROM INSERTED d
     );
     DECLARE @accountID INT=
     (
         SELECT TOP (1) i.AccountId
         FROM INSERTED i
     );
     INSERT INTO NotificationEmails
     (Recipient, 
      [Subject], 
      Body
     )
     VALUES
     (@accountID, 
      'Balance change for account: ' + CAST(@accountID AS varchar(20)), 
      'On' + CONVERT(varchar(30), GETDATE()) + 'your balance was changed from ' +  CAST(@oldSum AS varchar(20)) + ' to ' +  CAST(@newSum AS varchar(20)) + '.'
     );

GO

--11
USE Bank
GO

CREATE PROC usp_DepositMoney
(@AccountId   INT, 
 @MoneyAmount DECIMAL(18, 4)
)
AS
    BEGIN TRAN;
        DECLARE @account INT=
        (
            SELECT Id
            FROM dbo.Accounts a
            WHERE a.Id = @AccountId
        );
        IF(@account IS NULL)
            BEGIN
                ROLLBACK;
                RAISERROR('AccountId should be correct', 16, 1);
                RETURN;
        END;
        IF(@MoneyAmount < 0)
            BEGIN
                ROLLBACK;
                RAISERROR('Deposit should be positive', 16, 2);
                RETURN;
        END;
        UPDATE dbo.Accounts
          SET 
              Balance+=@MoneyAmount
        WHERE dbo.Accounts.Id = @AccountId;
        COMMIT;

GO

EXEC dbo.usp_DepositMoney 1, 10

SELECT * FROM dbo.Accounts a JOIN dbo.AccountHolders ah ON a.AccountHolderId = ah.Id WHERE a.Id = 1

GO

--12
USE Bank
GO

CREATE PROC usp_WithdrawMoney
(@AccountId   INT, 
 @MoneyAmount DECIMAL(18, 4)
)
AS
    BEGIN TRAN;
        DECLARE @account INT=
        (
            SELECT Id
            FROM dbo.Accounts a
            WHERE a.Id = @AccountId
        );
        IF(@account IS NULL)
            BEGIN
                ROLLBACK;
                RAISERROR('AccountId should be correct', 16, 1);
                RETURN;
        END;
        IF(@MoneyAmount < 0)
            BEGIN
                ROLLBACK;
                RAISERROR('Money amount should be positive', 16, 2);
                RETURN;
        END;
        DECLARE @sourceBalance DECIMAL(18, 4)=
        (
            SELECT a.Balance
            FROM dbo.Accounts a
            WHERE a.Id = @AccountId
        );
        IF(@sourceBalance < @MoneyAmount)
            BEGIN
                ROLLBACK;
                RAISERROR('Balance should be bigger than withdraw', 16, 3);
                RETURN;
        END;
        UPDATE dbo.Accounts
          SET 
              Balance-=@MoneyAmount
        WHERE dbo.Accounts.Id = @AccountId;
        COMMIT;

GO

--13
USE Bank
GO

CREATE PROC usp_TransferMoney
(@SenderId   INT, 
 @ReceiverId INT, 
 @Amount     DECIMAL(18, 4)
)
AS
    BEGIN TRAN;
        EXEC usp_WithdrawMoney 
             @SenderId, 
             @Amount;
        EXEC usp_DepositMoney 
             @ReceiverId, 
             @Amount;
        COMMIT;

GO


--14
USE Diablo
GO

SELECT *
FROM dbo.Users u
     JOIN dbo.UsersGames ug ON u.Id = ug.Id;

SELECT * FROM dbo.Items i
GO

CREATE TRIGGER tr_RestrictItems ON dbo.UserGameItems
INSTEAD OF INSERT
AS
     DECLARE @itemID INT=
     (
         SELECT i.ItemId
         FROM INSERTED i
     );
     DECLARE @userGameId INT=
     (
         SELECT i.UserGameId
         FROM INSERTED i
     );
     DECLARE @itemLevel INT=
     (
         SELECT i.MinLevel
         FROM dbo.Items i
         WHERE i.Id = @itemID
     );
     DECLARE @userGameLevel INT=
     (
         SELECT ug.[Level]
         FROM dbo.UsersGames ug
         WHERE ug.Id = ug.UserId
     );
     IF(@userGameLevel >= @itemLevel)
         BEGIN
             INSERT INTO dbo.UserGameItems
             (ItemId, 
              UserGameId
             )
             VALUES
             (@itemID, 
              @userGameId
             );
     END;
GO

SELECT *
FROM dbo.Users u
     JOIN dbo.UsersGames ug ON u.Id = ug.Id
     JOIN dbo.Games g ON ug.Id = g.Id
WHERE g.[Name] = 'Bali'
      AND u.Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos');

UPDATE dbo.UsersGames
  SET 
      dbo.UsersGames.Cash+=50000
WHERE dbo.UsersGames.GameId =
(
    SELECT g.Id
    FROM dbo.Games g
    WHERE g.[Name] = 'Bali'
)
      AND dbo.UsersGames.UserId IN
(
    SELECT Id
    FROM dbo.Users u
    WHERE u.Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
);

GO

CREATE PROC usp_BuyItem
(@UserId   INT, 
 @ItemId   INT, 
 @GameName VARCHAR(20)
)
AS
    BEGIN TRAN;
        DECLARE @user INT=
        (
            SELECT u.Id
            FROM dbo.Users u
            WHERE u.Id = @UserId
        );
        DECLARE @item INT=
        (
            SELECT i.Id
            FROM dbo.Items i
            WHERE i.Id = @ItemId
        );
        DECLARE @gameId INT=
        (
            SELECT g.Id
            FROM dbo.Games g
            WHERE g.[Name] = @GameName
        );
        IF(@user IS NULL
           OR @item IS NULL
           OR @gameId IS NULL)
            BEGIN
                RAISERROR('Invalid user, item or game!', 16, 1);
                ROLLBACK;
                RETURN;
        END;

        DECLARE @userCash DECIMAL(15, 2)=
        (
            SELECT ug.Cash
            FROM dbo.UsersGames ug
            WHERE ug.UserId = @UserId
                  AND ug.GameId = @gameId
        );
        DECLARE @itemPrice DECIMAL(15, 2)=
        (
            SELECT i.Price
            FROM dbo.Items i
            WHERE i.Id = @ItemId
        );
        IF(@userCash < @itemPrice)
            BEGIN
                RAISERROR('Insufficion funds!', 16, 2);
                ROLLBACK;
                RETURN;
        END;

        UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-=@itemPrice
        WHERE dbo.UsersGames.Id = @UserId
              AND dbo.UsersGames.GameId = @gameId;

        INSERT INTO dbo.UserGameItems
        (ItemId, 
         UserGameId
        )
        VALUES
        (@ItemId, 
         @gameId
        );

COMMIT;

GO

DECLARE @itemId INT= 251;

WHILE(@itemId <= 299)
    BEGIN
        EXEC usp_BuyItem 
             22, 
             @itemId, 
             'Bali';
        EXEC usp_BuyItem 
             37, 
             @itemId, 
             'Bali';
        EXEC usp_BuyItem 
             52, 
             @itemId, 
             'Bali';
        EXEC usp_BuyItem 
             6, 
             @itemId, 
             'Bali';
        SET @itemId+=1;
    END;

DECLARE @counter INT= 501;

WHILE(@itemId <= 539)
    BEGIN
        EXEC usp_BuyItem 
             22, 
             @itemId, 
             'Bali';
        EXEC usp_BuyItem 
             37, 
             @itemId, 
             'Bali';
        EXEC usp_BuyItem 
             52, 
             @itemId, 
             'Bali';
        EXEC usp_BuyItem 
             6, 
             @itemId, 
             'Bali';
        SET @itemId+=1;
    END;

GO

SELECT u.Username, 
       g.Name, 
       ug.Cash, 
       i.[Name]
FROM dbo.Users u
     JOIN dbo.UsersGames ug ON u.Id = ug.UserId
     JOIN dbo.Games g ON ug.GameId = g.Id
     JOIN dbo.UserGameItems ugi ON ug.Id = ugi.UserGameId
     JOIN dbo.Items i ON ugi.ItemId = i.Id
WHERE g.[Name] = 'Bali'
ORDER BY u.Username, 
         i.[Name];

GO


--15
USE Diablo
GO

DECLARE @userGameId INT=
(
    SELECT ug.Id
    FROM dbo.UsersGames ug
    WHERE ug.UserId = 9
          AND ug.GameId = 87
);
DECLARE @stamatCash DECIMAL(15, 2)=
(
    SELECT ug.Cash
    FROM dbo.UsersGames ug
    WHERE ug.Id = @userGameId
);
DECLARE @itemsPrice DECIMAL(15, 2)=
(
    SELECT SUM(i.Price) AS TotalPrice
    FROM dbo.Items i
    WHERE i.MinLevel BETWEEN 11 AND 12
);
IF(@stamatCash >= @itemsPrice)
    BEGIN
        BEGIN TRAN;
        UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-=@itemsPrice
        WHERE dbo.UsersGames.Id = @userGameId;
        INSERT INTO dbo.UserGameItems
        (ItemId, 
         UserGameId
        )
               SELECT i.Id, 
                      @userGameId
               FROM dbo.Items i
               WHERE i.MinLevel BETWEEN 11 AND 12;
        COMMIT;
END;
SET @stamatCash =
(
    SELECT ug.Cash
    FROM dbo.UsersGames ug
    WHERE ug.Id = @userGameId
);
SET @itemsPrice =
(
    SELECT SUM(i.Price) AS TotalPrice
    FROM dbo.Items i
    WHERE i.MinLevel BETWEEN 19 AND 21
);
IF(@stamatCash >= @itemsPrice)
    BEGIN
        BEGIN TRAN;
        UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-=@itemsPrice
        WHERE dbo.UsersGames.Id = @userGameId;
        INSERT INTO dbo.UserGameItems
        (ItemId, 
         UserGameId
        )
               SELECT i.Id, 
                      @userGameId
               FROM dbo.Items i
               WHERE i.MinLevel BETWEEN 19 AND 21;
        COMMIT;
END;
SELECT i.[Name]
FROM dbo.Users u
     JOIN dbo.UsersGames ug ON u.Id = ug.UserId
     JOIN dbo.Games g ON ug.GameId = g.Id
     JOIN dbo.UserGameItems ugi ON ug.Id = ugi.UserGameId
     JOIN dbo.Items i ON ugi.ItemId = i.Id
WHERE u.Username = 'Stamat'
      AND g.[Name] = 'Safflower'
ORDER BY i.[Name];

GO


--16
USE SoftUni
GO

CREATE PROC usp_AssignProject
(@emloyeeId INT, 
 @projectID INT
)
AS
    BEGIN TRAN;
        DECLARE @selectedEmpID INT=
        (
            SELECT e.EmployeeID
            FROM dbo.Employees e
            WHERE e.EmployeeID = @emloyeeId
        );
        DECLARE @selectedProjectID INT=
        (
            SELECT p.ProjectID
            FROM dbo.Projects p
            WHERE p.ProjectID = @projectID
        );
        IF(@selectedEmpID IS NULL
           OR @selectedProjectID IS NULL)
            BEGIN
                RAISERROR('Employee or project doesn''t exists!', 16, 2);
                ROLLBACK;
                RETURN;
        END;
        DECLARE @countEmpProjects INT=
        (
            SELECT COUNT(*)
            FROM dbo.EmployeesProjects ep
            WHERE ep.EmployeeID = @emloyeeId
        );
        IF(@countEmpProjects >= 3)
            BEGIN
                RAISERROR('The employee has too many projects!', 16, 1);
                ROLLBACK;
                RETURN;
        END;
        INSERT INTO dbo.EmployeesProjects
        (EmployeeID, 
         ProjectID
        )
        VALUES
        (@emloyeeId, 
         @projectID
        );
        COMMIT;

GO

--17
USE SoftUni
GO

CREATE TABLE Deleted_Employees
(EmployeeId   INT
 PRIMARY KEY IDENTITY, 
 FirstName    VARCHAR(50), 
 LastName     VARCHAR(50), 
 MiddleName   VARCHAR(50), 
 JobTitle     VARCHAR(50), 
 DepartmentId INT, 
 Salary       DECIMAL(15, 2)
);
GO

CREATE TRIGGER tr_DeletedEmployees ON dbo.Employees
FOR DELETE
AS
     INSERT INTO dbo.Deleted_Employees
     (FirstName, 
      LastName, 
      MiddleName, 
      JobTitle, 
      DepartmentId, 
      Salary
     )
            SELECT FirstName, 
                   LastName, 
                   MiddleName, 
                   JobTitle, 
                   DepartmentId, 
                   Salary
            FROM DELETED;