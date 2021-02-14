CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
SELECT f.Id, f.Name, Concat(f.Size, 'KB') Size
     FROM Files f
     WHERE f.Name LIKE '%.' + @fileExtension
     ORDER BY f.Id ASC, f.Name ASC, Size DESC