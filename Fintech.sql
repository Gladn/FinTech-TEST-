Create database Fintech
use Fintech


Create table Product(
Id bigint primary key identity,
Name varchar(100),
Price decimal(20,2))

Create table Links (
--LinksId bigint primary key identity, //был нужен для тестов
UpProductId bigint,
ProductId bigint,
Count int,
Foreign key (UpProductId) references Product(Id),
Foreign key (ProductId) references Product(Id),
CONSTRAINT UQ_Links_UpProductId_ProductId UNIQUE (UpProductId, ProductId))


INSERT INTO Product (Name, Price)
VALUES 
('Изделие 1', 800),
('Изделие 2', 100),
('Изделие 3', 400),
('Изделие 4', 400),
('Изделие 5', 300),
('Изделие 6', 20),
('Изделие 7', 1000),
('Изделие 8', 100);

INSERT INTO Links (UpProductId, ProductId, Count)
VALUES 
(null, 1, 1),
(1, 2, 10),
(1, 3, 2),
(3, 5, 2),
(1, 4, 1),
(4, 2, 1),
(4, 6, 5) ,
(null, 7, 1),
(7, 8, 20),
(7, 3, 10);



select * from Product
select * from Links


drop table Links
drop table Product


select * from Links as L
join Product as P on P.Id = L.ProductId


-- Thats my first successful try of using recursive cte -- 
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
INNER JOIN Product P ON L.ProductId = P.Id
INNER JOIN RecursiveCTE R ON L.UpProductId = R.ProductId
where L.UpProductId is not Null
) select * from RecursiveCTE


--2-------------------------

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
), reverseCTE AS (
select * from RecursiveCTE
where Level = 2

--UNION ALL 

)
SELECT * FROM reverseCTE


---------------------------


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
    WHERE L.UpProductId is not Null
), ReversedCTE AS (
    SELECT L.*, P.*, 3 AS Level,
    CAST(P.Price * L.Count as decimal(20,2)) as Total,
    CAST(0 as decimal(20,2)) as TotalCost
    FROM Links as L
    INNER JOIN Product as P ON L.ProductId = P.Id
    WHERE L.ProductId = (SELECT MAX(ProductId) FROM RecursiveCTE WHERE UpProductId IS NULL)

    UNION ALL

    SELECT L.*, P.*, R.Level - 1,
    CAST(P.Price * L.Count as decimal(20,2)) as Total,
    CAST(P.Price * L.Count + R.Total as decimal(20,2)) as TotalCost
    FROM Links L
    INNER JOIN Product p ON L.ProductId = P.Id
    INNER JOIN ReversedCTE R ON L.ProductId = R.UpProductId
)
SELECT * FROM ReversedCTE;





---------------------------------------
WITH RecursiveCTE AS (
SELECT P.Id,
       P.Name AS 'Изделие',
       L.Count AS 'Колво',
       P.Price AS 'Цена',
       1 AS Level,
       CAST(P.Id AS varchar(max)) AS SortPath
FROM Links L
JOIN Product P ON P.Id = L.ProductId
WHERE L.UpProductId IS NULL

UNION ALL

    SELECT
        P.Id,
        P.Name AS 'Изделие',
        L.Count AS 'Колво',
        P.Price AS 'Цена',
        R.Level + 1 AS Level,
        R.SortPath + '/' + CAST(P.Id AS varchar(max)) AS SortPath
    FROM
        Links L
    JOIN
        Product P ON P.Id = L.ProductId
    JOIN
        RecursiveCTE R ON R.Id = L.UpProductId
)
SELECT  
    REPLICATE('  ', (LEN(SortPath) - LEN(REPLACE(SortPath, '/', '')))) + Изделие AS 'Изделие',
    Колво,
    Цена,
	Level
FROM RecursiveCTE
ORDER BY SortPath;
