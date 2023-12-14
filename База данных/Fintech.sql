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
FOREIGN KEY (ProductId) REFERENCES Product(Id),
CONSTRAINT UC_UpProductId_ProductId UNIQUE (UpProductId, ProductId));


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
(9, 10, 5), 
(2, 6, 1);



SELECT * FROM Product
SELECT * FROM Links

--  drop table Links drop table Product

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
    Count INT,
    Price DEC(20,2),
    Level INT,
	HierarchyLevel INT,
	HierarchyPath VARCHAR(100),
	RootProductID INT,
	RootUpProductID INT,
);



WITH RecursiveCTE AS (
    SELECT
		L.UpProductId,
        L.ProductId,
        L.Count,
        P.Price,
		0 AS Level,
        3 AS HierarchyLevel,
		'/' + CAST(L.ProductId AS VARCHAR(MAX)) + '/' AS HierarchyPath,
        L.ProductId AS RootProductID,
		L.UpProductId AS RootUpProductID
    FROM
        Links AS L
        JOIN Product AS P ON L.ProductId = P.Id

    UNION ALL

    SELECT
		L.UpProductId,
        L.ProductId,
        L.Count,
        P.Price,
		R.Level + 1,	
        R.HierarchyLevel + 2,		
		R.HierarchyPath + CAST(L.ProductId AS VARCHAR(MAX)) + '/',
        R.RootProductID,
		R.RootUpProductID
    FROM
        Links L
        JOIN Product AS P ON L.ProductId = P.Id
        JOIN RecursiveCTE AS R ON L.UpProductId = R.ProductId
)   
INSERT INTO #TempTable (UpProductId, ProductId, Count, Price, Level, HierarchyLevel, HierarchyPath, RootProductID, RootUpProductID)
select * from RecursiveCTE


	SELECT DISTINCT T.UpProductId, T.ProductId, 
	(
        SELECT TOP 1 REPLICATE('   ', T.Level) + P.Name
        FROM #TempTable as T
        WHERE P.Id = T.ProductId 
		ORDER BY T.Level DESC
    ) AS Name,	
	T.Count, T.Price, 
	R.AmountChildTotalCost,
	COALESCE(R2.AmountChildCount, 0) as AmountChildCount,
	T.Level, T.HierarchyPath
	FROM #TempTable T
	join Links L on L.ProductId = T.ProductId
	Join Product P on P.Id = L.ProductId
	LEFT JOIN (
       SELECT RootUpProductID, RootProductID,
        SUM(Price*Count) AS AmountChildTotalCost
        FROM #TempTable	
	Group by RootProductID, RootUpProductID
	) AS R ON T.ProductId = R.RootProductID
	 LEFT JOIN (
        SELECT
            RootUpProductID,
            SUM(Count) AS AmountChildCount
        FROM #TempTable
        GROUP BY
            RootUpProductID			
    ) AS R2 ON T.ProductId = R2.RootUpProductID
	Where T.RootUpProductID is null and R.RootUpProductID = T.UpProductId or R.RootUpProductID  is null
	ORDER BY HierarchyPath


DROP TABLE #TempTable;

END;

EXEC ReportForProductLinks;

--  Drop proc ReportForProductLinks