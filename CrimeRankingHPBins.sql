USE CrimeProject
GO


WITH CTE1 -- CTE gives the number of each crime committed in each LSOA in each Year, 
AS		   -- the population of the LSOA at the time and the Normalised House price bin of the LSOA at the time
(
select distinct
	 f.LSOACode
	,d.yr [Year]
	,l.LSOAName
	,ct.CrimeType
	,count(*) OVER (Partition BY f.crimetypeid, l.[LSOACode], d.yr) [NoOfCrimesInLSOAInYr]
	,pop.Population
	,hp.NormHPBin5
	,hp.NormHPBin10
from FactTable f
inner join DimLocation l
	on f.LSOACode = l.LSOACode
inner join DimDate d
	on f.Date = d.dt
inner join DimCrimeType ct
	on f.CrimeTypeID = ct.CrimeTypeID
inner join census.LSOAPopulation pop
	on f.LSOACode = pop.LSOACode
	and d.yr = pop.Year
inner join property.LSOAHousePrices hp
	on f.LSOACode = hp.LSOACode
	and d.yr = hp.Year
WHERE d.[Yr] BETWEEN '2011' AND '2016'
--and l.[LSOAName] like 'southwark 00%'
)

,

CTE2 -- CTE returns number of each type of crime in each HP bin, the combined population 
AS	 -- of the LSOA-years that make up the bin and the crime rate /1000p in the bin,
(
SELECT
*
,sum([NoOfCrimesInLSOAInYr]) OVER (Partition BY [CrimeType], NormHPBin5) CrimesInHPBin
,sum(Population) OVER (Partition BY NormHPBin5, [CrimeType]) HPBinPop
,round(1000*sum([NoOfCrimesInLSOAInYr]) OVER (Partition BY [CrimeType], NormHPBin5) 
	/ cast(sum(Population) OVER (Partition BY NormHPBin5, [CrimeType]) AS float),2) [BinCrimeRate/1000p]
FROM CTE1
)

,

CTE3 -- CTE returns the ranking of each of the crime types in each HP bin
AS
(
select distinct
	 [CrimeType]
	,NormHPBin5
	,[BinCrimeRate/1000p]
	,dense_RANK() over (partition by NormHPBin5 order by [BinCrimeRate/1000p] desc) CrimeRankInHPBin
from CTE2
)

select -- This query gives the ranking of each of the crime types in each HP bin 
     CrimeType
    ,case	 -- Turned into floats to allow sequential plotting in Tableau
	   when NormHPBin5 = '1.6+' then 1.6
	   else cast(NormHPBin5 as float)
     end NormHPBin5
    ,[BinCrimeRate/1000p]
    ,CrimeRankInHPBin
into crime.CrimeRanksInHPBins
from cte3
where 1=1
--	and CrimeRankInHPBin between 1 and 4
--	and NormHPBin5 = '0.2'
--order by NormHPBin5, CrimeRankInHPBin


--select distinct -- This query gives the crime rate across a HP Bin for a given crime type
--	 [CrimeType]
--	,NormHPBin5
--	,[BinCrimeRate/1000p]
--from cte2
--where [CrimeType] = 'Anti-social behaviour'
--order by NormHPBin5
