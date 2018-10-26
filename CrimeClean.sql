use CrimeProject
go

/*
GENERAL NOTES
Some records for hillingdon had data in the wrong fields - updated table to move data across
Context column empty - not carried forward
	
*/


-- Set up clean crime table, ready to be turned into fact table

--IF object_id('[crime].[preFactTable]') IS NOT NULL 
--	BEGIN 
--		DROP table [crime].[preFactTable]
--	END
--go

SELECT DISTINCT [Crime ID]
	-- Add a day value to the date to 
	-- allow date functions to be performed on it
	,cast(([Month] + '-01') AS date) [Date]
	,[Reported by]
	,[Falls within]
	,Longitude
	,Latitude
	,Location
	,[LSOA code]
	-- Merge Violent Crime types to account for phase out
	,CASE
	 	WHEN [Crime type] = 'Violent Crime' 
		THEN 'Violence and sexual offences'
	 	ELSE [Crime type]
	 END [Crime type]
	,CASE -- Clean [Last outcome category]
	 	WHEN [Last outcome category] = ',' OR [Last outcome category] = '' 
		THEN 'Status update unavailable'
	 	WHEN [Last outcome category] LIKE '%,%' 
		THEN replace([Last outcome category],',','')
	 	ELSE [Last outcome category]
	 END [Last outcome category]
-- INTO crime.preFactTable
FROM ZRawData.Raw_MetCrimeRecords1
-- Take only LSOA codes found in London census data to 
-- restrict the sample to crimes that took place in London
WHERE [LSOA code] IN ( SELECT DISTINCT Codes 
	FROM [ZRawData].[Raw_2011Census1]
	)




SELECT * 
FROM Crime.MetCrimeRecords
WHERE [LSOA name] LIKE 'southwark 001a%'

SELECT DISTINCT -- This checks the first and last recorded incidence of each crime type
	-- 'Violent crime' was replaced with 'Violence and sexual offences' in May 2013
	-- There also seems to have been a change from 'Public disorder and weapons' to 
	-- 'Possession of weapons' and 'Public order' but it is not possible to differentiate before this date
	 [Crime type]
	,min([Year-month]) OVER(Partition BY [Crime type]) FirstRecord
	,max([Year-month]) OVER(Partition BY [Crime type]) LatestRecord
	,count(*) OVER(Partition BY [Crime type]) [NoOfCrimes]
FROM Crime.MetCrimeRecords
ORDER BY LatestRecord ASC,FirstRecord DESC
