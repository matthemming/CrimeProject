use CrimeProject

--Create London average house prices table

-- Build Annual London Average house price table
--IF object_id('Property.LDNAvgHousePrices') IS NOT NULL 
--	BEGIN 
--		DROP table Property.LDNAvgHousePrices
--	END
--go

--CREATE table Property.LDNAvgHousePrices
--(PriceID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, [Year] char(4),[AvgPrice] int)

--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('1995',107636)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('1996',108056)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('1997',122004)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('1998',142588)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('1999',151449)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2000',191828)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2001',215976)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2002',229739)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2003',262137)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2004',280127)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2005',303011)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2006',332617)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2007',370930)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2008',393928)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2009',386325)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2010',460037)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2011',477237)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2012',464102)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2013',505499)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2014',572327)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2015',608630)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2016',664516)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2017',682965)
--INSERT INTO Property.LDNAvgHousePrices 
--VALUES ('2018',757880)


-- Create unpivoted house prices by LSOA as a view

CREATE VIEW Vw_UnpivotedHousePrices
AS
(
SELECT
	[Local authority code]
	,[Local authority name]
	,[LSOA code]
	,[LSOA name]
	,Period
	,MedianHousePrice
FROM
(
SELECT 
* 
FROM [zRawData].[raw_LSOAHousePrices]
) L
UNPIVOT
(
MedianHousePrice FOR Period IN 
	([Year ending Dec 1995]
      ,[Year ending Mar 1996]
      ,[Year ending Jun 1996]
      ,[Year ending Sep 1996]
      ,[Year ending Dec 1996]
      ,[Year ending Mar 1997]
      ,[Year ending Jun 1997]
      ,[Year ending Sep 1997]
      ,[Year ending Dec 1997]
      ,[Year ending Mar 1998]
      ,[Year ending Jun 1998]
      ,[Year ending Sep 1998]
      ,[Year ending Dec 1998]
      ,[Year ending Mar 1999]
      ,[Year ending Jun 1999]
      ,[Year ending Sep 1999]
      ,[Year ending Dec 1999]
      ,[Year ending Mar 2000]
      ,[Year ending Jun 2000]
      ,[Year ending Sep 2000]
      ,[Year ending Dec 2000]
      ,[Year ending Mar 2001]
      ,[Year ending Jun 2001]
      ,[Year ending Sep 2001]
      ,[Year ending Dec 2001]
      ,[Year ending Mar 2002]
      ,[Year ending Jun 2002]
      ,[Year ending Sep 2002]
      ,[Year ending Dec 2002]
      ,[Year ending Mar 2003]
      ,[Year ending Jun 2003]
      ,[Year ending Sep 2003]
      ,[Year ending Dec 2003]
      ,[Year ending Mar 2004]
      ,[Year ending Jun 2004]
      ,[Year ending Sep 2004]
      ,[Year ending Dec 2004]
      ,[Year ending Mar 2005]
      ,[Year ending Jun 2005]
      ,[Year ending Sep 2005]
      ,[Year ending Dec 2005]
      ,[Year ending Mar 2006]
      ,[Year ending Jun 2006]
      ,[Year ending Sep 2006]
      ,[Year ending Dec 2006]
      ,[Year ending Mar 2007]
      ,[Year ending Jun 2007]
      ,[Year ending Sep 2007]
      ,[Year ending Dec 2007]
      ,[Year ending Mar 2008]
      ,[Year ending Jun 2008]
      ,[Year ending Sep 2008]
      ,[Year ending Dec 2008]
      ,[Year ending Mar 2009]
      ,[Year ending Jun 2009]
      ,[Year ending Sep 2009]
      ,[Year ending Dec 2009]
      ,[Year ending Mar 2010]
      ,[Year ending Jun 2010]
      ,[Year ending Sep 2010]
      ,[Year ending Dec 2010]
      ,[Year ending Mar 2011]
      ,[Year ending Jun 2011]
      ,[Year ending Sep 2011]
      ,[Year ending Dec 2011]
      ,[Year ending Mar 2012]
      ,[Year ending Jun 2012]
      ,[Year ending Sep 2012]
      ,[Year ending Dec 2012]
      ,[Year ending Mar 2013]
      ,[Year ending Jun 2013]
      ,[Year ending Sep 2013]
      ,[Year ending Dec 2013]
      ,[Year ending Mar 2014]
      ,[Year ending Jun 2014]
      ,[Year ending Sep 2014]
      ,[Year ending Dec 2014]
      ,[Year ending Mar 2015]
      ,[Year ending Jun 2015]
      ,[Year ending Sep 2015]
      ,[Year ending Dec 2015]
      ,[Year ending Mar 2016]
      ,[Year ending Jun 2016]
      ,[Year ending Sep 2016]
      ,[Year ending Dec 2016]
      ,[Year ending Mar 2017]
      ,[Year ending Jun 2017]
      ,[Year ending Sep 2017]
      ,[Year ending Dec 2017]
      ,[Year ending Mar 2018])
) Up
)

-- Set up Clean LSOA house prices table - filter by LSOA codes present in London Census data,
-- extract median house prices for periods ending Dec
-- Normalise median house prices against London averages for each year
-- Put normalised house prices into bins of 0.05 up to 1.55, then 1.6+

IF object_id('Property.LSOAHousePrices') IS NOT NULL 
	BEGIN 
		DROP table Property.LSOAHousePrices
	END
go

SELECT
	 H.[LSOA code] LSOACode
	,H.[LSOA name] LSOAName
	,right(H.Period,4) [Year]
	,cast(H.MedianHousePrice AS float) MedianHousePrice
	,cast(A.AvgPrice AS float) LDNAvgHousePrice
	-- Divide LSOA median house price by London avg. to normalise
	,round((cast(H.MedianHousePrice AS float) / A.AvgPrice),3) NormalisedHousePrice
	,CASE -- Group normalised prices into bins of 0.05
		WHEN round(cast(H.MedianHousePrice AS float) / A.AvgPrice/5,2)*5 > 1.55 THEN 1.6
		WHEN round(cast(H.MedianHousePrice AS float) / A.AvgPrice/5,2)*5 < 0.25 THEN 0.25
		ELSE round(cast(H.MedianHousePrice AS float) / A.AvgPrice/5,2)*5
	 END NormHPBin5
	,CASE -- Group normalised prices into bins of 0.1
		WHEN round(cast(H.MedianHousePrice AS float) / A.AvgPrice,1) > 1.55 THEN 1.6
		WHEN round(cast(H.MedianHousePrice AS float) / A.AvgPrice,1) < 0.3 THEN 0.3
		ELSE round(cast(H.MedianHousePrice AS float) / A.AvgPrice,1)
	 END NormHPBin10
INTO 
Property.LSOAHousePrices 
FROM Vw_UnpivotedHousePrices H
		left JOIN 
		[Property].[LDNAvgHousePrices] A
		ON right(H.Period,4) = A.[Year]
WHERE Period LIKE '%ending Dec%' -- Choose values for years ending December to get 1 price per year
	AND [LSOA code] IN ( SELECT DISTINCT Codes 
	FROM [ZRawData].[Raw_2011Census1]
	)
ALTER table Property.LSOAHousePrices
ADD PriceID int IDENTITY PRIMARY KEY
go


-- Not used
--;with cte
--as
--(
--select distinct
--	 round(NormalisedHousePrice/5, 2)*5 NormalisedHousePrice
--	,count(*) over (partition by round(NormalisedHousePrice/5, 2)*5) Count
--	,count(*) over (partition by (select 'a')) total
--	,round(count(*) over (partition by round(NormalisedHousePrice/5, 2)*5)/cast(count(*) over (partition by (select 'a')) as float) *100, 2) [%]
--from property.LSOAHousePrices
--order by round(NormalisedHousePrice/5, 2)*5
--)

--select
--	 *
--	,SUM([%]) OVER(ORDER BY NormalisedHousePrice ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Col2
--from cte

--select -- Shows on a map where LSOAs in a given price band are located
--	 p.[LSOA name]
--	,p.NormHPBin
--	,g.geom
--from [property].[LSOAHousePrices] p
--left join [dbo].[LSOA_2011_London_gen_MHW] g
--	on p.[LSOA code] = g.LSOA11CD
--where p.Year = 2016
--and p.NormHPBin between '1.01' and '1.2'