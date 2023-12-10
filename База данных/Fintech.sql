CREATE DATABASE Fintech
USE Fintech


CREATE TABLE Product(
Id BIGINT PRIMARY KEY IDENTITY,
Name VARCHAR(100),
Price DECIMAL(20,2));


CREATE TABLE Links (
LinkId BIGINT PRIMARY KEY IDENTITY,
UpProductId BIGINT,
ProductId BIGINT,
Count INT,
FOREIGN KEY (UpProductId) REFERENCES Product(Id),
FOREIGN KEY (ProductId) REFERENCES Product(Id));


INSERT INTO Product (Name, Price)
VALUES 
('Изделие 1', 800),
('Изделие 2', 100),
('Изделие 3', 400),
('Изделие 4', 400),
('Изделие 5', 300),
('Изделие 6', 20),
('Изделие 7', 1000),
('Изделие 8', 100),
('Изделие 9', 1000),
('Изделие 10', 500);


INSERT INTO Links (UpProductId, ProductId, Count)
VALUES 
(null, 1, 1),
(1, 2, 10),
(1, 3, 2),
(3, 5, 2),
(1, 4, 1),
(4, 6, 1),
(4, 7, 5) ,
(null, 8, 1),
(8, 9, 10),
(9, 10, 5);


SELECT * FROM Product
SELECT * FROM Links


SELECT UpProductId, C.Name, ProductId, P.Name, Count, P.Price FROM Links AS L
join Product AS P ON P.Id = L.ProductId
left join Product AS c ON C.Id = L.UpProductId



-----Запрос для вкладки 3-----------------------------------------------------
CREATE PROCEDURE ReportForProductLinks
AS
BEGIN
CREATE TABLE #TempTable (
    UpProductId BIGINT,
    ProductId BIGINT,
    Name VARCHAR(100),
    Count INT,
    Price DEC(20,2),
    AmountChildTotalCost DEC(20,2),
	AmountChildCount INT,
    Level INT
);

WITH RecursiveCTE AS (
    SELECT
        L.ProductId,
        L.Count,
        P.Price,
        0 AS Level,
        L.ProductId AS RootProductID,
		L.UpProductId AS RootUpProductID
    FROM
        Links AS L
        JOIN Product AS P ON L.ProductId = P.Id

    UNION ALL

    SELECT
        L.ProductId,
        L.Count,
        P.Price,
        R.Level + 1,
        R.RootProductID,
		R.RootUpProductID
    FROM
        Links L
        JOIN Product AS P ON L.ProductId = P.Id
        JOIN RecursiveCTE AS R ON L.UpProductId = R.ProductId
)
INSERT INTO #TempTable (UpProductId, ProductId, Name, Count, Price, AmountChildTotalCost, AmountChildCount, Level)
SELECT
    L.UpProductId,
    L.ProductId,
    (
        SELECT TOP 1 REPLICATE('  ', R.Level) + P.Name
        FROM RecursiveCTE as R
        WHERE P.Id = R.ProductId
        ORDER BY R.Level DESC
    ) AS Name,
    L.Count,
    P.Price,
    ISNULL(R.AmountChildTotalCost, 0) AS AmountChildTotalCost,
	ISNULL(R2.AmountChildCount, 0) AS AmountChildCount,
    R.Level

FROM
    Links AS L
    JOIN Product AS P ON L.ProductId = P.Id
    LEFT JOIN (
        SELECT
            RootProductID, 
            SUM(Price*Count) AS AmountChildTotalCost,
            MAX(Level) AS Level
        FROM
            RecursiveCTE
        GROUP BY
            RootProductID
    ) AS R ON P.Id = R.RootProductID
	    LEFT JOIN (
        SELECT
            RootUpProductID,
            SUM(Count) AS AmountChildCount,
            MAX(Level) AS Level
        FROM
            RecursiveCTE
        GROUP BY
            RootUpProductID
    ) AS R2 ON P.Id = R2.RootUpProductID;

SELECT * FROM #TempTable;
DROP TABLE #TempTable;
END;

EXEC ReportForProductLinks;
-----------------------------------------------------------------------------
