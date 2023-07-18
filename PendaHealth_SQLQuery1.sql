-- VIEW THE TABLES --
SELECT *
FROM
	Hospital..DiagnosisTbl$

SELECT *
FROM
	Hospital..InvoiceTbl$

SELECT *
FROM
	Hospital..VisitTbl$

-- JOIN THE THREE TABLES --
SELECT 
	VisitTbl$.VisitCode, VisitTbl$.PatientCode, VisitTbl$.VisitDateTime, VisitTbl$.MedicalCenter, VisitTbl$.VisitCategory, VisitTbl$.Payor, VisitTbl$.NPS_Score,
	InvoiceTbl$.Amount, DiagnosisTbl$.Diagnosis
FROM
	Hospital..VisitTbl$
LEFT JOIN InvoiceTbl$ ON VisitTbl$.VisitCode = InvoiceTbl$.VisitCode
LEFT JOIN DiagnosisTbl$ ON VisitTbl$.VisitCode = DiagnosisTbl$.VisitCode

-- I will export the cleaned dataset. I did the cleaning using Python Jupyter that I saved as  Clean_Data.xlxs. The table is called "Sheet1$"--

-- View the table--
SELECT *
FROM
	Hospital..Sheet1$

-- EDA QUERIES--

-- How many visits did Kimathi Street and Pipeline medical centers' have from May 2022 and September 2022?--
SELECT 
	COUNT(*) AS TotalVisits
FROM
	Hospital..Sheet1$
WHERE
	Date  >= '01/05/2022' 
	AND Date < '01/10/2022'
	AND MedicalCenter IN ('Kimathi Street', 'Pipeline')

-- What was the most common diagnosis in 2022 for Tassia and Embakasi branches combined?--
SELECT
	Diagnosis,
	COUNT(*) AS TotalDiagnosis
FROM
	Hospital..Sheet1$
WHERE
	MedicalCenter IN ('Tassia', 'Embakasi')
	AND YEAR(CONVERT(DATETIME, [Date], 103)) = 2022
GROUP BY
	Diagnosis
ORDER BY
	COUNT(*) DESC

--Which payor was the most profitable (in absolute numbers) for Penda Health in 2022? {Assume a gross average margin of 30% per visit}--
SELECT
	Payor,
	ROUND(SUM(Amount * 0.3),0) AS Profit
FROM
	Hospital..Sheet1$
WHERE
	YEAR(CONVERT(DATETIME, [Date], 103)) = 2022
GROUP BY
	Payor
ORDER BY
	Profit DESC

--Which medical center was the least profitable  (in absolute numbers)  in 2022?  {Assume a gross average margin of 30% per visit}.--
SELECT
	MedicalCenter,
	ROUND(SUM(Amount * 0.3),0) AS Profit
FROM
	Hospital..Sheet1$
WHERE
	YEAR(CONVERT(DATETIME, [Date], 103)) = 2022
GROUP BY
	MedicalCenter
ORDER BY
	Profit ASC

--What was the average spend per visit for visits that had a diagnosis of acute gastritis?--
SELECT
	Diagnosis,
	ROUND(AVG(Amount),0) AS AverageSpendPerVisit
FROM
	Hospital..Sheet1$
WHERE
	Diagnosis = 'acute gastritis'
GROUP BY
	Diagnosis
ORDER BY
	AverageSpendPerVisit DESC

-- In 2022, how many unique patients experienced a blended healthcare approach in their healthcare journey?--
SELECT
	COUNT(DISTINCT PatientCode) AS UniquePatients
FROM
	Hospital..Sheet1$
WHERE
	YEAR(CONVERT(DATETIME, [Date], 103)) = 2022
	AND VisitCategory IN ('Telemedicine Visit', 'In-person Visit')

--Calculate the Net Promoter Score (NPS) in Q3 2022. {Please note that valid NPS scores range from 0 to 10}--
SELECT 
	ROUND(((SUM(CASE WHEN YEAR(CONVERT(DATETIME, [Date], 103)) = 2022 AND MONTH(CONVERT(DATETIME, [Date], 103)) >= 7 
	AND MONTH(CONVERT(DATETIME, [Date], 103)) <= 9 THEN CONVERT(FLOAT, NPS_Score) END) / COUNT(NPS_Score)) * 100), 0) AS NPS
FROM 
	Hospital..Sheet1$
WHERE 
	YEAR(CONVERT(DATETIME, [Date], 103)) = 2022 AND 
	MONTH(CONVERT(DATETIME, [Date], 103)) >= 7 AND 
	MONTH(CONVERT(DATETIME, [Date], 103)) <= 9 AND
	NPS_Score >= 0 AND 
	NPS_Score < 11;

--In 2022 what proportion of visits in Penda Health were second visits?{A first visit is when a patient visits Penda Health for the very first time, a second visit is when the same patient visits again i.e. a second time and so on}--
SELECT 
	ROUND((COUNT(DISTINCT PatientCode) - COUNT(DISTINCT CASE WHEN PatientCode IS NOT NULL THEN PatientCode END)) * 100.0 / COUNT(DISTINCT PatientCode), 
	0) AS SecondVisitProportion
FROM 
	Hospital..Sheet1$
WHERE 
	YEAR(CONVERT(DATETIME, [Date], 103)) = 2022


