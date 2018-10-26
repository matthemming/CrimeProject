
;WITH CTE1
AS
(
SELECT DISTINCT 
	 LSOACode
	,count(*) OVER (PARTITION BY LSOACode) CrimesInLSOA
FROM FactTable 
WHERE year(date) BETWEEN 2011 AND 2016
)
,
CTE2
AS
(
SELECT
	 *
	,avg(CrimesInLSOA) OVER (Partition BY (SELECT 'd')) AverageLSOACrimes
	,round(CrimesInLSOA / cast(avg(CrimesInLSOA) OVER (Partition BY (SELECT 'd')) AS float), 2) RatioToAvg
	,sum(CrimesInLSOA) OVER (Partition BY (SELECT 'd')) TotalCrimes
	,round(CrimesInLSOA / cast(sum(CrimesInLSOA) OVER (Partition BY (SELECT 'd')) AS float) * 100, 2) [%OfTotalCrimes]
	,PERCENTILE_CONT(0.25) Within GROUP (ORDER BY CrimesInLSOA) OVER () [Q1]
	,PERCENTILE_CONT(0.5) Within GROUP (ORDER BY CrimesInLSOA) OVER () [Q2]
	,PERCENTILE_CONT(0.75) Within GROUP (ORDER BY CrimesInLSOA) OVER () [Q3]
	,PERCENTILE_CONT(0.75) Within GROUP (ORDER BY CrimesInLSOA) OVER () - PERCENTILE_CONT(0.25) Within GROUP (ORDER BY CrimesInLSOA) OVER () IQRange
FROM CTE1
)

SELECT -- Identify outliers as LSOAs containing more than 1.5xIQR above the third quartile (Q3 + 1.5 * IQR)
	 LSOACode
	,CrimesInLSOA
	,RatioToAvg
	,Q3 + 1.5*IQRange OutlierLimit
	,Q3 + 3*IQRange LooserOutlierLimit
	,CASE 
		WHEN CrimesInLSOA > Q3 + 1.5*IQRange THEN 'Exclude Outlier'
		ELSE 'Include'
	 END [Include/Exclude]
FROM CTE2 
ORDER BY CrimesInLSOA DESC