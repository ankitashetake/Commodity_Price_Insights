USE commodity_db;

SELECT * FROM commodities_info;
SELECT * FROM price_details;
SELECT * FROM region_info;
/************************************************************************************************
Question 1: Get the common commodities between the Top 10 costliest commodities of 2019 and 2020.
************************************************************************************************/
WITH top_2019 as
(SELECT Commodity_Id, AVG(Retail_Price)
FROM price_details
WHERE YEAR (DATE)= 2019
GROUP BY Commodity_Id
ORDER BY AVG(Retail_Price) DESC
LIMIT 10), 
top_2020 as
(SELECT Commodity_Id, AVG(Retail_Price)
FROM price_details
WHERE YEAR (DATE)= 2020
GROUP BY Commodity_Id
ORDER BY AVG(Retail_Price) DESC
LIMIT 10)
SELECT DISTINCT commodity
FROM top_2019 t19
INNER JOIN  top_2020 t20
ON t19.Commodity_Id = t20.Commodity_Id
INNER JOIN commodities_info ci
ON ci.id = t19.Commodity_Id;

/************************************************************************************************
Question 2: What is the maximum difference between the prices of a commodity at one place vs the other 
for the month of Jun 2020? Which commodity was it for?

Algorithm:
Input: price_details: Id, Region_Id, Commodity_Id, Date and Retail_Price; commodities_info: Id and Commodity
Expected Output: Commodity | price difference;  Retain the info for highest difference
Step 1: Filter Jun 2020 in Date column of price_details
Step 2: Aggregation – MIN(retail_price), MAX(retail_price) group by commodity
Step 3: Compute the difference between the Max and Min retail price
Step 4: Sort in descending order of price difference; Retain the top most row
************************************************************************************************/
SELECT Commodity,MAX(Retail_Price)- min(Retail_Price) as max_diff
FROM price_details pd
INNER JOIN commodities_info ci
ON ci.id = pd.Commodity_id
WHERE MONTH(DATE)=06 AND YEAR(DATE)=2020
GROUP BY Commodity 
ORDER BY max_diff DESC
LIMIT 1;
/************************************************************************************************
Question 3: Arrange the commodities in order based on the number of varieties in which they are available, 
with the highest one shown at the top. Which is the 3rd commodity in the list?

Algorithm:
Input: commodities_info: Commodity and Variety
Expected Output: Commodity | Variety count;  Sort in descending order of Variety count
Step 1: Aggregation – COUNT(DISTINCT variety), group by Commodity
Step 2: Sort the final table in descending order of Variety count
************************************************************************************************/
SELECT commodity, COUNT(DISTINCT Variety) AS Variety_count
 FROM commodities_info
 GROUP BY commodity 
 ORDER BY Variety_count DESC;

/************************************************************************************************
Question 4: In the state with the least number of data points available. 
Which commodity has the highest number of data points available?

Algorithm:
Input: price_details: Id, region_id, commodity_id region_info: Id and State commodities_info: Id and Commodity
Expected Output: commodity;  Expecting only one value as output
Step 1: Join region info and price details using the Region_Id from price_details with Id from region_info
Step 2: From result of Step 1, perform aggregation – COUNT(Id), group by State; 
Step 3: Sort the result based on the record count computed in Step 2 in ascending order; 
		Filter for the top State
Step 4: Filter for the state identified from Step 3 from the price_details table
Step 5: Aggregation – COUNT(Id), group by commodity_id; Sort in descending order of count 
Step 6: Filter for top 1 value and join with commodities_info to get the commodity name
************************************************************************************************/
SELECT State, Commodity,COUNT(pd.id) as data_count
FROM region_info ri
INNER JOIN price_details pd
ON ri.id = pd.Region_Id
INNER JOIN commodities_info ci
ON ci.id= pd.Commodity_Id
WHERE State =
(SELECT State 
FROM region_info ri
INNER JOIN price_details pd
ON ri.id = pd.Region_Id
GROUP BY State
ORDER BY COUNT(pd.id)
LIMIT 1) 
GROUP BY State,Commodity
ORDER BY data_count DESC
LIMIT 1; 
/*******************************************************************************************************
Question 5: What is the price variation of commodities for each city from Jan 2019 to Dec 2020. 
			Which commodity has seen the highest price variation and in which city?
Algorithm:
Input: price_details: Id, region_id, commodity_id, date, retail_price 
	   region_info: Id and City 
	   commodities_info: Id and Commodity
Expected Output: Commodity | city | Start Price | End Price | Variation absolute | Variation Percentage;  
Sort in descending order of variation %

Step 1: Filter for Jan 2019 from Date column of the price_details table
Step 2: Filter for Dec 2020 from Date column of the price_details table
Step 3: Do an inner join between the results from Step 1 and Step 2 on region_id and commodity id
Step 4: Name the price from Step 1 result as Start Price and Step 2 result as End Price
Step 5: Calculate Variations in absolute and percentage; 
		Sort the final table in descending order of Variation Percentage
Step 6: Filter for 1st record and join with region_info, commodities_info to get city and commodity name
********************************************************************************************************/
CREATE VIEW full_table AS 
SELECT 
      ri.State,
      ri.Centre,
      ci.Commodity,
      pd.Date,
      pd.Retail_Price
FROM region_info ri
JOIN price_details pd ON ri.Id = pd.Region_Id
JOIN commodities_info ci ON ri.ID = pd.Commodity_Id;

WITH jan_2019 AS
( SELECT Centre,Commodity,Retail_Price AS Start_price
FROM full_table 
WHERE MONTH(DATE) = 1
AND YEAR(DATE)=2019),

dec_2020 AS 
( SELECT Centre,Commodity,Retail_Price AS End_price
FROM full_table 
WHERE MONTH(DATE) = 12
AND YEAR(DATE)=2020)

SELECT 
    j.Centre,
    j.Commodity,
    j.Start_price,
    d.End_price,
     ABS(d.End_price - j.start_price) AS variation_abs
	FROM jan_2019 j
    JOIN dec_2020 d
    ON j.Centre = d.Centre AND J.Commodity = d.Commodity
    ORDER BY variation_abs DESC
    LIMIT 1;