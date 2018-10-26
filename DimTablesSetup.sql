USE [CrimeProject]
GO

/*
!!! If Dim Tables are reset they will need to be re-enriched !!!
*/


-- Build Authority dimension table
--IF object_id('DimAuthority') IS NOT NULL 
--	BEGIN 
--		DROP table DimAuthority
--	END
--go

--SELECT DISTINCT 
--	 isnull(NULLIF([Reported by],''),'Unknown') Authority
--INTO DimAuthority 
--FROM Crime.PreFactTable
--go

--ALTER table DimAuthority
--ADD AuthorityID tinyint IDENTITY PRIMARY KEY
--go


---- Build CrimeType dimension table
--IF object_id('DimCrimeType') IS NOT NULL 
--	BEGIN 
--		DROP table DimCrimeType
--	END
--go

--SELECT DISTINCT 
--	 [Crime type] CrimeType
--INTO DimCrimeType 
--FROM Crime.PreFactTable
--go

--ALTER table DimCrimeType
--ADD CrimeTypeID tinyint IDENTITY PRIMARY KEY
--go


---- Build Outcome dimension table
--IF object_id('DimOutcome') IS NOT NULL 
--	BEGIN 
--		DROP table DimOutcome
--	END
--go

--SELECT DISTINCT 
--	 [Last outcome category] Outcome
--INTO DimOutcome 
--FROM Crime.PreFactTable
--go

--ALTER table DimOutcome
--ADD OutcomeID tinyint IDENTITY PRIMARY KEY
--go

--ALTER table DimOutcome
--ADD CONSTRAINT PK_DimOutcome_OutcomeID PRIMARY KEY (OutcomeID)
--go


-- Build FactTable
IF object_id('FactTable') IS NOT NULL 
	BEGIN 
		DROP table FactTable
	END
go

SELECT 
	 F.[Crime ID] CrimeID
	,F.[Date]
	,A.AuthorityID ReportedBy
	,A2.AuthorityID FallsWithin
	,F.[Longitude]
	,F.[Latitude]
	,F.[Location]
	,F.[LSOA code] LSOACode
	,C.CrimeTypeID
	,O.OutcomeID
	,pop.PopID
	,HP.PriceID
INTO [FactTable] 
FROM [Crime].[PreFactTable] F -- 6571915rows
--Join to dimension tables to replace text information with numerical foreign keys
INNER JOIN DimAuthority A
	ON isnull(NULLIF(F.[Reported by],''),'Unknown') = A.Authority -- 6571915rows
INNER JOIN DimAuthority A2
	ON F.[Falls within] = A2.Authority -- 6571915rows
INNER JOIN DimCrimeType C
	ON F.[Crime type] = C.CrimeType -- 6571915rows
INNER JOIN DimOutcome O
	ON F.[Last outcome category] = O.Outcome -- 6571915rows
LEFT JOIN census.LSOAPopulation pop
	ON YEAR(f.Date) = pop.Year -- 6571915rows
	AND f.[LSOA code] = pop.LSOACode
LEFT JOIN property.LSOAHousePrices HP
	ON YEAR(f.Date) = HP.Year -- 6571915rows
	AND f.[LSOA code] = HP.LSOACode
go
ALTER table [FactTable]
ADD CrimeRecordID int IDENTITY PRIMARY KEY

ALTER table FactTable
ADD CONSTRAINT FK_DimAuthority_Authority FOREIGN KEY (ReportedBy) 
REFERENCES DimAuthority (AuthorityID)
go

ALTER table FactTable
ADD CONSTRAINT FK_DimDate_Date FOREIGN KEY (date) 
REFERENCES DimDate (Dt)

ALTER table FactTable
ADD CONSTRAINT FK_DimCrimeType_CrimeType FOREIGN KEY (CrimeTypeID) 
REFERENCES DimCrimeType (CrimeTypeID)

ALTER table FactTable
ADD CONSTRAINT FK_DimOutcome_OutcomeID FOREIGN KEY (OutcomeID) 
REFERENCES DimOutcome (OutcomeID)

ALTER table FactTable
ADD CONSTRAINT FK_DimLocation_LSOACode FOREIGN KEY (LSOACode) 
REFERENCES DimLocation (LSOACode)

ALTER table FactTable
ADD CONSTRAINT FK_Population_PopID FOREIGN KEY (PopID) 
REFERENCES Census.LSOAPopulation (PopID)

ALTER table FactTable
ADD CONSTRAINT FK_LSOAHousePrices_PriceID FOREIGN KEY (PriceID) 
REFERENCES [property].[LSOAHousePrices] (PriceID)