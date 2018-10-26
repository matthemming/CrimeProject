

;WITH cte
AS
(
SELECT DISTINCT 
	 LSOACode
	,NormHPBin5
FROM Property.LSOAHousePrices
WHERE year BETWEEN 2011 AND 2016
)
,
cte2
AS
(
SELECT DISTINCT 
	 LSOACode 
	,count(*) OVER (Partition BY LSOACode) NumberOfBins
	,min(NormHPBin5) OVER (Partition BY LSOACode) MinBin
	,max(NormHPBin5) OVER (Partition BY LSOACode) MaxBin
	,round(max(NormHPBin5) OVER (Partition BY LSOACode)
		- min(NormHPBin5) OVER (Partition BY LSOACode),2) RangeOfBinMovement
FROM cte
)

SELECT
	 *
INTO HPBinMovement 
FROM cte2

--SELECT DISTINCT 
--	 RangeOfBinMovement
--	,count(*) OVER (Partition BY RangeOfBinMovement) LSOAs
----INTO BinMovementProfile 
--FROM Cte2 
--ORDER BY RangeOfBinMovement

--SELECT DISTINCT 
--	 NumberOfBins
--	,count(*) OVER (Partition BY NumberOfBins) LSOAs
--	,round(100 * count(*) OVER (Partition BY NumberOfBins) / cast(count(*) OVER (Partition BY (SELECT 'd')) AS float),0) PcOfLSOAs
----INTO BinMobilityNumbers 
--FROM Cte2 
--ORDER BY NumberOfBins





