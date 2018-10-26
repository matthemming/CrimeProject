USE CrimeProject
go



IF object_id('raw_LSOAsofInterest') IS NOT NULL 
	BEGIN 
		DROP table Raw_LSOAsofInterest
	END
GO

-- Use this if fact table already set up
SELECT DISTINCT -- Select unique LSOAs from fact table into new table to speed up queries
	 F.[LSOACode]
	,C.[LSOA name] LSOAName
INTO Raw_LSOAsofInterest 
FROM [Dbo].[FactTable] F -- 4832 rows
INNER JOIN [ZRawData].[Raw_MetCrimeRecords1] C -- 4832 rows
ON F.[LSOACode] = C.[LSOA code]
GO

-- Use this before fact table set up
--SELECT DISTINCT -- Select unique LSOAs from London census table into new table to speed up queries
--	 [Codes] LSOACode
--	,[Names] LSOAName
--INTO Raw_LSOAsofInterest 
--FROM zRawData.raw_2011Census1
--GO

IF object_id('DimLocation') IS NOT NULL 
	BEGIN 
		DROP table DimLocation
	END
GO

SELECT -- Set up DimLocation, enriching with LSOA Name, Borough and Shape Code
	 L.[LSOACode] LSOACode
	,L.[LSOAName] LSOAName
	,G.MSOA11CD MSOACode
	,G.MSOA11NM MSOAName
	,substring(L.[LSOAName],1,charindex('0',L.[LSOAName])-1) Borough
INTO DimLocation 
FROM Raw_LSOAsofInterest L -- 4832 rows
INNER JOIN Dbo.LSOA_2011_London_gen_MHW G -- 4832 rows
ON L.[LSOACode] = G.LSOA11CD;

-- Make LSOACode not null to allow it to be used as PK
ALTER table Dimlocation
ALTER COLUMN LSOACode varchar(500) NOT NULL;

-- Make LSOACode PK
ALTER table Dimlocation
ADD CONSTRAINT PK_DimLocation_LSOACode PRIMARY KEY (LSOACode)