

use project 


------# data pre processing-----
-------1. Data Exploration and Cleaning


-- Countries in 'incidence-of-tuberculosis-sdgs' not in 'tuberculosis-deaths-by-age'
SELECT [Entity] AS CountryName FROM [dbo].[ incidence-of-tuberculosis-sdgs]
EXCEPT
SELECT [Entity] FROM [dbo].[tuberculosis-deaths-by-age];

-- Countries in 'tuberculosis-deaths-by-age' not in 'incidence-of-tuberculosis-sdgs'
SELECT [Entity] AS CountryName FROM [dbo].[tuberculosis-deaths-by-age]
EXCEPT
SELECT [Entity] FROM [dbo].[ incidence-of-tuberculosis-sdgs]




SELECT [Entity] AS CountryName FROM [dbo].[tuberculosis-case-detection-rate]
EXCEPT
SELECT [Entity] FROM [dbo].[4- tuberculosis-treatment-success-rate-by-type]


SELECT [Entity] AS CountryName FROM [dbo].[4- tuberculosis-treatment-success-rate-by-type]
EXCEPT
SELECT [Entity] FROM [dbo].[tuberculosis-case-detection-rate]     



------------- joining two tables-------
SELECT    a.[Estimated_incidence_of_all_forms_of_tuberculosis],b.* into #newtable
FROM [dbo].[ incidence-of-tuberculosis-sdgs] AS a
 JOIN [dbo].[tuberculosis-deaths-by-age] AS b
ON a.[Entity] = b.[Entity]
ORDER BY a.[Entity]
-------------203 same countries-----
------139380-----   

SELECT    a.*,b.[Indicator_Treatment_success_rate_new_TB_cases],b.[Indicator_Treatment_success_rate_for_patients_treated_for_MDR_TB],b.[Indicator_Treatment_success_rate_XDR_TB_cases] 
into #secondtable
FROM #newtable AS a
INNER JOIN [dbo].[4- tuberculosis-treatment-success-rate-by-type] AS b
ON a.[Entity] = b.[Entity]
ORDER BY a.[Entity]  
----------------2911890------------- 


select * from  #secondtable
----------------

SELECT    a.*,b.[Case_detection_rate_all_forms]
into dbo.finalTB
FROM #secondtable AS a
INNER JOIN [dbo].[tuberculosis-case-detection-rate] AS b
ON a.[Entity] = b.[Entity]
ORDER BY a.[Entity]   
-------65251170------
  

 
delete  from [dbo].[finalTB] where [Indicator_Treatment_success_rate_new_TB_cases] is Null 
delete from [dbo].[finalTB] where [Indicator_Treatment_success_rate_for_patients_treated_for_MDR_TB] is Null
delete from [dbo].[finalTB] where [Indicator_Treatment_success_rate_XDR_TB_cases] is Null 
delete from [dbo].[finalTB] where [Case_detection_rate_all_forms] is Null  
 

select distinct * into dbo.TB from [dbo].[finalTB]   


------------
--------1.2 Descriptive Statistics and Initial Observations-----------

-- Summary statistics for tuberculosis incidence
SELECT 
    MIN([Estimated_incidence_of_all_forms_of_tuberculosis]) AS min_incidence,
    MAX([Estimated_incidence_of_all_forms_of_tuberculosis]) AS max_incidence,
    AVG([Estimated_incidence_of_all_forms_of_tuberculosis]) AS avg_incidence,
    STDEV([Estimated_incidence_of_all_forms_of_tuberculosis]) AS stddev_incidence
FROM [dbo].[TB]    

--------min_incidence : 2.1 ,max_incidence : 1590 , avg_incidence : 263.0318866162682 , stddev_incidence : 273.00749104379094


--------Analyze the trends of TB incidence rates over the years to understand how TB is evolving globally or in specific countries
SELECT [Year], [Entity], AVG([Estimated_incidence_of_all_forms_of_tuberculosis]) AS avg_incidence_rate
FROM [dbo].[finalTB]
GROUP BY [Year],[Entity]
ORDER BY year, avg_incidence_rate DESC   


SELECT [Year], [Entity], AVG([Estimated_incidence_of_all_forms_of_tuberculosis]) AS avg_incidence_rate
FROM [dbo].[finalTB]
GROUP BY [Year],[Entity]
ORDER BY year, avg_incidence_rate  


--------Eswatini -- 971.5652173913044

--------Develop a predictive model using historical data to forecast future TB incidence rates. This could involve:

select distinct *  into dbo.TB from [dbo].[finalTB] 

------2. Predictive Model for TB Incidence Rates
-----Develop a predictive model using historical data to forecast future TB incidence rates. This could involve:

-------Creating a linear regression model in SQL to predict next year's incidence rates based on past data.
-------Using rolling averages 
SELECT   year, [Entity], 
       AVG([Estimated_incidence_of_all_forms_of_tuberculosis]) OVER (PARTITION BY [Entity] ORDER BY year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_incidence
FROM [dbo].[TB]
ORDER BY[Entity], year    



-------- Age-wise TB Mortality Analysis



SELECT 
    year,
    CONVERT(FLOAT, Deaths_Age_70_plus) / CONVERT(FLOAT, Total_Deaths) * 100 AS Pct_Deaths_Age_70_plus,
    CONVERT(FLOAT, Deaths_Age_50_to_69) / CONVERT(FLOAT, Total_Deaths) * 100 AS Pct_Deaths_Age_50_to_69,
    CONVERT(FLOAT, Deaths_Age_15_to_49) / CONVERT(FLOAT, Total_Deaths) * 100 AS Pct_Deaths_Age_15_to_49,
    CONVERT(FLOAT, Deaths_Age_5_to_14) / CONVERT(FLOAT, Total_Deaths) * 100 AS Pct_Deaths_Age_5_to_14,
    CONVERT(FLOAT, Deaths_Age_Under_5) / CONVERT(FLOAT, Total_Deaths) * 100 AS Pct_Deaths_Age_Under_5
FROM
    (SELECT 
        year, 
        SUM(CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_70_years_Number])) AS Deaths_Age_70_plus,
        SUM(CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_50_69_years_Number])) AS Deaths_Age_50_to_69,
        SUM(CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_15_49_years_Number])) AS Deaths_Age_15_to_49,
        SUM(CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_5_14_years_Number])) AS Deaths_Age_5_to_14,
        SUM(CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_Under_5_Number])) AS Deaths_Age_Under_5,
        SUM(CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_70_years_Number])
            + CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_50_69_years_Number])
            + CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_15_49_years_Number])
            + CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_5_14_years_Number])
            + CONVERT(BIGINT, [Deaths_Tuberculosis_Sex_Both_Age_Under_5_Number])) AS Total_Deaths
    FROM 
        [dbo].[TB]
    GROUP BY 
        year
    ) AS SubQuery
ORDER BY 
    year DESC 




------------ Avg_success rate------
SELECT [Entity], AVG([Indicator_Treatment_success_rate_for_patients_treated_for_MDR_TB]) AS avg_success_rate_mdr, AVG([Indicator_Treatment_success_rate_XDR_TB_cases]) AS avg_success_rate_xdr, AVG([Indicator_Treatment_success_rate_new_TB_cases])
 AS avg_success_rate_newcases FROM [dbo].[TB]
GROUP BY [Entity]
ORDER BY avg_success_rate_mdr DESC, avg_success_rate_xdr DESC,avg_success_rate_newcases DESC  ;



----3. Comparative and Correlational Analysis------

-----3.1 Correlation Between HIV Prevalence and Tuberculosis Incidence-----

--------- Correlation between HIV prevalence and tuberculosis incidence


SELECT distinct
    t1.[Entity],
     t1.[Year],
    t1.[Estimated_incidence_of_all_forms_of_tuberculosis], 
    [Estimated_HIV_in_incident_tuberculosis],
    ([Estimated_HIV_in_incident_tuberculosis] * [Estimated_incidence_of_all_forms_of_tuberculosis]) / (AVG([Estimated_HIV_in_incident_tuberculosis]) OVER() * AVG([Estimated_incidence_of_all_forms_of_tuberculosis]) OVER()) AS correlation_factor
FROM [dbo].[TB] t1
JOIN [dbo].[5- tuberculosis-patients-with-hiv-share] t2 ON t1.[Entity] = t2.[Entity] AND t1.year = t2.year
ORDER BY correlation_factor DESC;  

SELECT TOP 1000*
FROM [dbo].[TB] 


select * from [dbo].[TB]














  

