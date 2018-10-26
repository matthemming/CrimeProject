USE CrimeProject
go

CREATE PROC Usp_BuildDimDate
-- Stored proc to create date table with incrementally increasing 
-- values from a defined start point
AS 
	IF object_id('DimDate') IS NOT NULL 
		BEGIN 
			DROP table DimDate
		END  

;WITH Cte 
AS 
( --anchor table sets start date
SELECT cast('1992-12-01' AS date) AS dt
	,year(cast('1992-12-01' AS date)) Yr
	,month(cast('1992-12-01' AS date)) Mnth
	,CASE 
		WHEN month(cast('1992-12-01' AS date)) IN (12,1,2) THEN 'Winter' 
		WHEN month(cast('1992-12-01' AS date)) IN (3,4,5) THEN 'Spring' 
		WHEN month(cast('1992-12-01' AS date)) IN (6,7,8) THEN 'Summer' 
		ELSE 'Autumn' 
	 END Season 
UNION ALL
-- Unioned table references Cte and adds new dates in 1 month increments
SELECT 
	 dateadd(Mm,1,dt)
	,year(dateadd(Mm,1,dt))
	,month(dateadd(Mm,1,dt))
	,CASE 
		WHEN month(dateadd(Dd,1,dt)) IN (12,1,2) THEN 'Winter' 
		WHEN month(dateadd(Dd,1,dt)) IN (3,4,5) THEN 'Spring' 
		WHEN month(dateadd(Dd,1,dt)) IN (6,7,8) THEN 'Summer' 
		ELSE 'Autumn' 
	 END Season
FROM Cte 
WHERE dateadd(Mm,1,dt) < dateadd(Yy,1,getdate()) 
)  

SELECT
 * 
INTO DimDate 
FROM Cte OPTION (Maxrecursion 0)
go

EXEC Usp_BuildDimDate;

ALTER table DimDate
ALTER COLUMN dt date NOT NULL ;

ALTER table DimDate
ADD CONSTRAINT PK_DimDate_dt PRIMARY KEY (dt)