Create database Fintech
use Fintech


Create table Product(
Id bigint primary key identity,
Name varchar(100),
Price decimal(20,2))

Create table Links (
UpProductId bigint,
ProductId bigint,
Count int,
NodeHierarchy HIERARCHYID,
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

INSERT INTO Links (UpProductId, ProductId, Count, NodeHierarchy)
VALUES 
(null, 1, 1, HIERARCHYID::GetRoot()),
(1, 2, 10,HIERARCHYID::Parse('/1/')),
(1, 3, 2,HIERARCHYID::Parse('/2/')),
(3, 5, 2,HIERARCHYID::Parse('/2/1/')),
(1, 4, 1,HIERARCHYID::Parse('/3/')),
(4, 2, 1,HIERARCHYID::Parse('/4/2/')),
(4, 6, 5,HIERARCHYID::Parse('/4/6/')) ,
(null, 7, 1, HIERARCHYID::GetRoot()),
(7, 8, 20),
(7, 3, 10),
(3,2,10);

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
(7, 3, 10),
(3,2,10);

select * from Product
select * from Links


drop table Links
drop table Product


select * from Links as L
join Product as P on P.Id = L.ProductId


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
         L.ProductId as RootID, 
		 0 as level
  from Links L
    join Product P on L.ProductId = P.Id
  union all  
  select L.ProductId,  
         L.Count, 
		 P.Price,
         C.RootID,
		 C.level + 1
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
             group by RootID , Price
             ) as S  
    on P.Id = S.RootID  


order by P.Id  
option (maxrecursion 0);