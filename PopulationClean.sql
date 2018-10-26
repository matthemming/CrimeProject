USE CrimeProject
go

IF object_id('Census.LSOAPopulation ') IS NOT NULL 
	BEGIN 
		DROP table Census.LSOAPopulation
	END
go

WITH CTE1 
AS
(
SELECT
	 R11.[Area Codes] [LSOA Code]
	,R11.[All Ages] [2011]
	,R12.[All Ages] [2012]
	,R13.[All Ages] [2013]
	,R14.[All Ages] [2014]
	,R15.[All Ages] [2015]
	,R16.[All Ages] [2016]
FROM ZRawData.Raw_2011Pop R11
INNER JOIN ZRawData.Raw_2012Pop R12
ON R11.[Area Codes] = R12.[Area Codes]
INNER JOIN ZRawData.Raw_2013Pop R13
ON R12.[Area Codes] = R13.[Area Codes]
INNER JOIN ZRawData.Raw_2014Pop R14
ON R13.[Area Codes] = R14.[Area Codes]
INNER JOIN ZRawData.Raw_2015Pop R15
ON R14.[Area Codes] = R15.[Area Codes]
INNER JOIN ZRawData.Raw_2016Pop R16
ON R15.[Area Codes] = R16.[Area Codes]
)

SELECT 
	 -- Surrogate key PopID
	 row_number() OVER (ORDER BY [LSOA Code]) PopID
	,[LSOA Code] LSOACode
	,[Year]
	,[Population]
INTO 
Census.LSOAPopulation 
FROM ( 
SELECT 
	 * 
FROM CTE1 ) P 
UNPIVOT 
( [Population] FOR [Year] IN ([2011],[2012],[2013],
									  [2014],[2015],[2016]) ) Up

-- Make PopID not null to allow it to be used as PK
ALTER TABLE Census.LSOAPopulation ALTER COLUMN PopID INTEGER NOT NULL

-- Make PopID PK
ALTER TABLE Census.LSOAPopulation   
ADD CONSTRAINT PK_PopID PRIMARY KEY CLUSTERED (PopID);  
GO 

--ALTER SCHEMA ZRawData
--Transfer [Dbo].[LSOA_2011_London_gen_MHW]