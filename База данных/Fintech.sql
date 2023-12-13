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
('������� 1', 800),
('������� 2', 100),
('������� 3', 400),
('������� 4', 400),
('������� 5', 300),
('������� 6', 20),
('������� 7', 1000),
('������� 8', 100),
('������� 9', 1000),
('������� 10', 500);


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

--  drop table Links drop table Product

SELECT UpProductId, C.Name, ProductId, P.Name, Count, P.Price FROM Links AS L
join Product AS P ON P.Id = L.ProductId
left join Product AS c ON C.Id = L.UpProductId



-----������ ��� ������� 3-----------------------------------------------------
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
    Level INT,
	HierarhyLevel INT,
	HierarchyPath VARCHAR(100),
	RootUpProductID INT,
	RootUpProductID2 INT,
	RootProductID2 INT
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
INSERT INTO #TempTable (
						UpProductId, 
						ProductId, Name, Count, Price, AmountChildTotalCost, AmountChildCount
						, Level, HierarhyLevel, HierarchyPath,RootUpProductID,RootUpProductID2,RootProductID2
						)
SELECT DISTINCT
    L.UpProductId,
    L.ProductId,
    (
        SELECT TOP 1 REPLICATE('   ', R.Level) + P.Name
        FROM RecursiveCTE as R
        WHERE P.Id = R.ProductId
		ORDER BY R.Level DESC
    ) AS Name,
    L.Count,
    P.Price,
    ISNULL(R.AmountChildTotalCost, 0) AS AmountChildTotalCost,
	ISNULL(R2.AmountChildCount, 0) AS AmountChildCount,
    R3.Level,
	R3.HierarchyLevel,
	R3.HierarchyPath,
	R3.RootUpProductID, 
	R2.RootUpProductID,
	R.RootProductID
FROM
    Links AS L
    JOIN Product AS P ON L.ProductId = P.Id
    LEFT JOIN (
       SELECT RootUpProductID, RootProductID,
        SUM(Price*Count) AS AmountChildTotalCost
        FROM
            RecursiveCTE		  
	Group by RootProductID, RootUpProductID
    ) AS R ON P.Id = R.RootProductID
	    LEFT JOIN (
        SELECT
            RootUpProductID,
            SUM(Count) AS AmountChildCount
        FROM
            RecursiveCTE
        GROUP BY
            RootUpProductID			
    ) AS R2 ON P.Id = R2.RootUpProductID
	LEFT JOIN (
        SELECT
			*
        FROM
            RecursiveCTE
		WHERE  RootUpProductID is null AND LEN(HierarchyPath) = HierarchyLevel
    ) AS R3 ON L.ProductId = R3.ProductId


	SELECT DISTINCT T.UpProductId, T.ProductId,T.Name, AmountChildTotalCost, AmountChildCount, HierarchyPath FROM #TempTable T
	JOIN Links L on L.ProductId = T.ProductId
	join Product P on P.Id = L.ProductId
	WHERE T.UpProductId IS NULL OR SUBSTRING(HierarchyPath, LEN(HierarchyPath) - 3, 1) = CAST(T.UpProductId AS NVARCHAR(10))
	ORDER BY HierarchyPath

DROP TABLE #TempTable;

END;

EXEC ReportForProductLinks;

--  Drop proc ReportForProductLinks