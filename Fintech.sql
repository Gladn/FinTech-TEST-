Create database Fintech
use Fintech


Create table Product(
Id bigint primary key identity,
Name varchar(100),
Price decimal(20,2))

Create table Links (
LinkId bigint primary key identity,
UpProductId bigint,
ProductId bigint,
Count int,
Foreign key (UpProductId) references Product(Id),
Foreign key (ProductId) references Product(Id))

--------------------------------------------------------------------------
--Create table Links (
--UpProductId bigint,
--ProductId bigint,
--Count int,
--NodeHierarchy HIERARCHYID,
--Foreign key (UpProductId) references Product(Id),
--Foreign key (ProductId) references Product(Id),
--CONSTRAINT UQ_Links_UpProductId_ProductId UNIQUE (UpProductId, ProductId))
--------------------------------------------------------------------------


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


select * from Product
select * from Links


drop table Links
drop table Product


select UpProductId, C.Name, ProductId, P.Name, Count, P.Price from Links as L
join Product as P on P.Id = L.ProductId
left join Product as c on C.Id = L.UpProductId



--------------Версия Price-----------------------------------------------------
Create table #TempTable (
UpProductId bigint,
ProductId bigint,
Name varchar(100),
Count int,
Price dec(18,2),
AmountChild int

);


;With RecursiveCTE as (  
  select L.ProductId,  
         L.Count,  
		 P.Price,
         L.ProductId as RootID
  from Links L
    join Product P on L.ProductId = P.Id
  
  union all  
  
  select L.ProductId,  
         L.Count,   
		 P.Price,
         R.RootID
  from Links L
    join Product P on L.ProductId = P.Id
    join RecursiveCTE R on L.UpProductId = R.ProductId  
)  
INSERT INTO #TempTable (UpProductId, ProductId, Name, Count, Price, AmountChild)
SELECT L.UpProductId AS UpProductId,   
       L.ProductId AS ProductId,   
       P.Name,  
       L.Count,  
	   P.Price,
       ISNULL(R.AmountChild, 0) AS AmountChild

FROM Links L
JOIN Product P ON L.ProductId = P.Id
LEFT JOIN (  
             SELECT RootID,  
                    SUM(Price*Count) AS AmountChild  
             FROM RecursiveCTE
             GROUP BY RootID  
             ) AS R  ON P.Id = R.RootID
option (maxrecursion 0);

SELECT * FROM  #TempTable;
DROP TABLE #TempTable;






-----------------Версия Count
Create table #TempTable (
UpProductId bigint,
ProductId bigint,
Name varchar(100),
Count int,
Price dec(18,2),
AmountChild int

);


;With RecursiveCTE as (  
  select L.ProductId,  
         L.Count,  
		 P.Price,
         L.UpProductId as RootID
  from Links L
    join Product P on L.ProductId = P.Id
  
  union all  
  
  select L.ProductId,  
         L.Count,   
		 P.Price,
         R.RootID
  from Links L
    join Product P on L.ProductId = P.Id
    join RecursiveCTE R on L.UpProductId = R.ProductId  
)  
INSERT INTO #TempTable (UpProductId, ProductId, Name, Count, Price, AmountChild)
SELECT L.UpProductId AS UpProductId,   
       L.ProductId AS ProductId,   
       P.Name,  
       L.Count,  
	   P.Price,
       ISNULL(R.AmountChild, 0) AS AmountChild

FROM Links L
JOIN Product P ON L.ProductId = P.Id
LEFT JOIN (  
             SELECT RootID,  
                    SUM(Count) AS AmountChild  
             FROM RecursiveCTE
             GROUP BY RootID  
             ) AS R  ON P.Id = R.RootID

--Order by P.Id  
--option (maxrecursion 0);

SELECT * FROM  #TempTable;
DROP TABLE #TempTable;
----------ВАРИАНТ 111--------------------------------------------
CREATE TABLE #TempTable (
    UpProductId BIGINT,
    ProductId BIGINT,
    Name VARCHAR(100),
    Count INT,
    Price DEC(20,2),
    AmountChildTotalCost DEC(20,2),
	AmountChildCount Int,
    Level INT
);

WITH RecursiveCTE AS (
    SELECT
        L.ProductId,
        L.Count,
        P.Price,
        0 AS Level,
        L.ProductId AS RootID,
		L.UpProductId as RootID2
    FROM
        Links L
        JOIN Product P ON L.ProductId = P.Id

    UNION ALL

    SELECT
        L.ProductId,
        L.Count,
        P.Price,
        R.Level + 1,
        R.RootID,
		R.RootID2
    FROM
        Links L
        JOIN Product P ON L.ProductId = P.Id
        JOIN RecursiveCTE R ON L.UpProductId = R.ProductId
)
INSERT INTO #TempTable (UpProductId, ProductId, Name, Count, Price, AmountChildTotalCost, AmountChildCount,Level)
SELECT
    L.UpProductId AS UpProductId,
    L.ProductId AS ProductId,
    (
        SELECT TOP 1 REPLICATE('  ', R.Level) + P.Name
        FROM RecursiveCTE R
        WHERE P.Id = R.ProductId
        ORDER BY R.Level DESC -- Order by Level in descending order to get the topmost indentation
    ) AS Name,
    L.Count,
    P.Price,
    ISNULL(R.AmountChildTotalCost, 0) AS AmountChildTotalCost,
	ISNULL(R2.AmountChildCount, 0) AS AmountChildCount,
    R.Level

FROM
    Links L
    JOIN Product P ON L.ProductId = P.Id
    LEFT JOIN (
        SELECT
            RootID, 
            SUM(Price*Count) AS AmountChildTotalCost,
            MAX(Level) AS Level
        FROM
            RecursiveCTE
        GROUP BY
            RootID
    ) AS R ON P.Id = R.RootID
	    LEFT JOIN (
        SELECT
            RootID2,
            SUM(Count) AS AmountChildCount,
            MAX(Level) AS Level
        FROM
            RecursiveCTE
        GROUP BY
            RootID2
    ) AS R2 ON P.Id = R2.RootID2;
-- Select and view the contents of the temporary table
SELECT * FROM #TempTable;

-- Drop the temporary table
DROP TABLE #TempTable;
-------------ВАРИАН2-----------------------------------------
CREATE TABLE #TempTable (
    UpProductId BIGINT,
    ProductId BIGINT,
    Name VARCHAR(100),
    Count INT,
    Price DEC(20,2),
    AmountChildTotalCost DEC(20,2),
	AmountChildCount Int,
    Level INT
);

WITH RecursiveCTE AS (
    SELECT
        L.ProductId,
        L.Count,
        P.Price,
        0 AS Level,
        L.ProductId AS RootID,
		L.UpProductId as RootID2
    FROM
        Links L
        JOIN Product P ON L.ProductId = P.Id
		Left JOIN Product C ON L.UpProductId = C.Id

    UNION ALL

    SELECT
        L.ProductId,
        L.Count,
        P.Price,
        R.Level + 1,
        R.RootID,
		R.RootID2
    FROM
        Links L
        JOIN Product P ON L.ProductId = P.Id
        JOIN RecursiveCTE R ON L.UpProductId = R.ProductId
)
INSERT INTO #TempTable (UpProductId, ProductId, Name, Count, Price, AmountChildTotalCost, AmountChildCount,Level)
SELECT
    L.UpProductId AS UpProductId,
    L.ProductId AS ProductId,
    (
        SELECT TOP 1 REPLICATE('  ', R.Level) + P.Name
        FROM RecursiveCTE R
        WHERE P.Id = R.ProductId
        ORDER BY R.Level DESC -- Order by Level in descending order to get the topmost indentation
    ) AS Name,
    L.Count,
    P.Price,
    ISNULL(R.AmountChildTotalCost, 0) AS AmountChildTotalCost,
	ISNULL(R2.AmountChildCount, 0) AS AmountChildCount,
    R.Level

FROM
    Links L
    JOIN Product P ON L.ProductId = P.Id
    LEFT JOIN (
        SELECT
            RootID, 
            SUM(Price*Count) AS AmountChildTotalCost,
            MAX(Level) AS Level
        FROM
            RecursiveCTE
        GROUP BY
            RootID
    ) AS R ON P.Id = R.RootID
	    LEFT JOIN (
        SELECT
            RootID2,
            SUM(Count) AS AmountChildCount,
            MAX(Level) AS Level
        FROM
            RecursiveCTE
        GROUP BY
            RootID2
    ) AS R2 ON P.Id = R2.RootID2;
-- Select and view the contents of the temporary table
SELECT * FROM #TempTable;

-- Drop the temporary table
DROP TABLE #TempTable;
-------------------------------------------------------------

Create table #TempTable (
UpProductId bigint,
ProductId bigint,
Name varchar(100),
Count int,
Price dec(18,2),
AmountChild int
,AmountChild2 dec(18,2)
);


;With RecursiveCTE as (  
  select L.ProductId,  
         L.Count,  
		 P.Price,
         L.UpProductId as RootID,
		 L.ProductId as RootID2
  from Links L
    join Product P on L.ProductId = P.Id
  
  union all  
  
  select L.ProductId,  
         L.Count,  
		 P.Price,
         R.RootID,
		 R.RootID2
  from Links L
    join Product P on L.ProductId = P.Id
    join RecursiveCTE R on L.UpProductId = R.ProductId  
)  select * from RecursiveCTE
INSERT INTO #TempTable (UpProductId, ProductId, Name, Count, Price, AmountChild, AmountChild2)
SELECT DISTINCT L.UpProductId AS UpProductId,   
       L.ProductId AS ProductId,   
       P.Name,  	   
       L.Count,  
	   P.Price,
       ISNULL(R.AmountChild, 0) AS AmountChild
	   ,ISNULL(R2.AmountChild2, 0) AS AmountChild2 
FROM Links L
JOIN Product P ON L.ProductId = P.Id
LEFT JOIN (  
             SELECT RootID,  
                    SUM(Count) AS AmountChild  
             FROM RecursiveCTE
             GROUP BY RootID  
             ) AS R ON P.Id = R.RootID
LEFT JOIN (
			SELECT RootID2,  
                  SUM(Price*Count) AS AmountChild2  
             FROM RecursiveCTE
             GROUP BY RootID2
			) as R2	 ON P.Id = R2.RootID2;	 

--Order by P.Id  
--option (maxrecursion 0);

SELECT * FROM  #TempTable;
DROP TABLE #TempTable;












-- 1 ----------------------------------------------------------
WITH RecursiveCTE AS (
SELECT L.*, P.*, 0 AS Level, 
CAST(P.Price * L.Count as INT) as TotalCost
FROM Links as L
INNER JOIN Product as P ON L.ProductId = P.Id
WHERE L.UpProductId is Null

UNION ALL

SELECT L.*, P.*, R.Level + 1, 
CAST(R.TotalCost + P.Price * L.Count as INT) as TotalCost
FROM Links L
INNER JOIN Product P ON L.ProductId = P.Id
INNER JOIN RecursiveCTE R ON L.UpProductId = R.ProductId
where L.UpProductId is not Null
) select * from RecursiveCTE


-- 2 ----------------------------------------------------------
WITH RecursiveCTE AS (
SELECT L.*, P.*, 0 AS Level, 
CAST(P.Price * L.Count as decimal(20,2)) as Total, 
CAST(0 as decimal(20,2)) as TotalCost
FROM Links as L
INNER JOIN Product as P ON L.ProductId = P.Id
WHERE L.UpProductId is Null

UNION ALL

SELECT L.*, P.*, R.Level + 1, 
CAST(P.Price * L.Count as decimal(20,2)) as Total,
CAST(P.Price * L.Count + R.Total as decimal(20,2)) as TotalCost
FROM Links L
INNER JOIN Product p ON L.ProductId = P.Id
INNER JOIN RecursiveCTE R ON L.UpProductId = R.ProductId
where L.UpProductId is not Null
), 

reverseCTE AS (
select UpProductId, ProductId, Count, Id, Name, Price, Level
--, 2 as newlvl,
,CAST(Price * Count as decimal(20,2)) as Total
,ROW_NUMBER() OVER (PARTITION BY UpProductId ORDER BY ProductId) AS RowNum
from RecursiveCTE R
 WHERE Level = 2

UNION ALL 

Select R.UpProductId, R.ProductId, R.Count, R.Id, R.Name, R.Price, R.Level
--,RE.newlvl - 1,
,CAST(R.Price * R.Count + RE.Total as decimal(20,2)) as Total
,RE.RowNum
from RecursiveCTE as R
join reverseCTE RE on R.ProductId=RE.UpProductId 
Where RE.Level > 1
)
SELECT * FROM reverseCTE



-- 3 ----------------------------------------------------------
-- Создание временной таблицы для хранения рассчитанных стоимостей


;with C as  
(  
  select L.ProductId,  
         L.Count,  
         L.UpProductId as RootID  
  from Links L
    join Product P on L.ProductId = P.Id
  union all  
  select L.ProductId,  
         L.Count,   
         C.RootID  
  from Links L
    join Product P on L.ProductId = P.Id
    join C   
      on L.UpProductId = C.ProductId  
)  
--select * from C
select L.UpProductId as UpProductId,   
		L.ProductId as ProductId,   
       P.Name,  
       L.Count,  
       S.AmountIncludingChildren  
from Links L
  join Product P on L.ProductId = P.Id
  inner join (  
             select RootID,  
                    sum(Count) as AmountIncludingChildren  
             from C  
             group by RootID  
             ) as S  
    on P.Id = S.RootID  
order by P.Id  
option (maxrecursion 0);


;with C as  
(  
  select L.ProductId,  
         L.Count,
		 P.Price,
         L.ProductId as RootID 
  from Links L
    join Product P on L.ProductId = P.Id
  union all  
  select L.ProductId,  
         L.Count, 
		 P.Price,
         C.RootID
  from Links L
    join Product P on L.ProductId = P.Id
    join C   
      on L.UpProductId = C.ProductId  
)  
--select * from C
select L.UpProductId as UpProductId,   
		L.ProductId as ProductId,   
       P.Name,
	   P.Price,
       L.Count,
       S.AmountIncludingChildren  
from Links L
  join Product P on L.ProductId = P.Id
  inner join (  
             select RootID, 
                    sum(Price*Count) as AmountIncludingChildren  
             from C  
             group by RootID
             ) as S  
    on P.Id = S.RootID  


order by P.Id  
option (maxrecursion 0);

CREATE TABLE dbo.Hierarchy 
(
    ID INT NOT NULL PRIMARY KEY,
    ParentID INT NULL,
        CONSTRAINT [FK_parent] FOREIGN KEY ([ParentID]) REFERENCES dbo.Hierarchy([ID]),
    hid HIERARCHYID,
    Amount INT NOT null
);

INSERT INTO [dbo].[Hierarchy]
        ( [ID], [ParentID], [Amount] )
VALUES  
    (1, NULL, 100 ),
    (2, 1, 50),
    (3, 1, 50),
    (4, 2, 58),
    (5, 2, 7),
    (6, 3, 10),
    (7, 3, 20)
SELECT * FROM dbo.[Hierarchy] AS [h];

WITH cte AS (
    SELECT  [h].[ID] ,
            [h].[ParentID] ,
            CAST('/' + CAST(h.[ID] AS VARCHAR(10)) + '/' AS VARCHAR(MAX)) AS [h],
            [h].[hid]
    FROM    [dbo].[Hierarchy] AS [h]
    WHERE   [h].[ParentID] IS NULL

    UNION ALL

    SELECT  [h].[ID] ,
            [h].[ParentID] ,
            CAST([c].[h] + CAST(h.[ID] AS VARCHAR(10)) + '/' AS VARCHAR(MAX)) AS [h],
            [h].[hid]
    FROM    [dbo].[Hierarchy] AS [h]
    JOIN    [cte] AS [c]
            ON [h].[ParentID] = [c].[ID]
)
UPDATE [h]
SET hid = [cte].[h]
FROM cte
JOIN dbo.[Hierarchy] AS [h]
    ON [h].[ID] = [cte].[ID];

	Select * from [Hierarchy]

	SELECT p.id, SUM([c].[Amount])
FROM dbo.[Hierarchy] AS [p]
JOIN [dbo].[Hierarchy] AS [c]
    ON c.[hid].IsDescendantOf(p.[hid]) = 1
GROUP BY [p].[ID];



