-- DATA ANALYSIS

-- Find the unique categories in the data
SELECT DISTINCT Category
FROM category;

-- Show the purchase which had the highest cost
SELECT MAX(Cost)
FROM data;

-- Query to show only first 20 rows of data
SELECT *
FROM data
LIMIT 20;

-- show the unique company names where money has been spent
SELECT DISTINCT Company, Cost
FROM data
WHERE Cost > 0;

-- How many unique days has money been spent in each month
-- Create a month column
SELECT EXTRACT(MONTH from Date) AS Month, COUNT(DISTINCT Date) AS number_of_dates
FROM data
GROUP BY Month;

-- For the above question show it in descending order
SELECT EXTRACT(MONTH from Date) AS Month, COUNT(DISTINCT Date) AS Number_of_Dates
FROM data
GROUP BY Month
ORDER BY Number_of_Dates DESC;

-- Show only data of category id 3,4
SELECT *
FROM data
WHERE CategoryID IN (3, 4);

-- What is highest category_id of expense in march
SELECT CategoryID, SUM(Cost) as Total_Cost
FROM data
WHERE EXTRACT(MONTH from Date) = 3
GROUP BY CategoryID
ORDER BY Total_Cost DESC;

-- Which store had the highest expense in may
SELECT Company, SUM(Cost) as Total_Cost
FROM data
WHERE EXTRACT(MONTH from Date) = 5
GROUP BY Company
ORDER BY Total_Cost DESC;

-- Which category had the lowest total number in february
SELECT c.Category, SUM(d.Cost) as Total_Cost
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE EXTRACT(MONTH from Date) = 2
GROUP BY Category
ORDER BY Total_Cost;

-- Show the data only where shop name contains the letter w
SELECT *
FROM data
WHERE Company LIKE '%w%';

-- Find a way to get the category based on category ID
SELECT c.Category, d.CategoryID, d.Company, d.Cost, d.Date
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID;

-- Is there any category ID not present in the data table
SELECT c.CategoryID, c.Category, d.CategoryID, d.Company, d.Cost, d.Date
FROM category c
         LEFT JOIN data d ON d.CategoryID = c.CategoryID
WHERE d.CategoryID IS NULL;

-- Show categories with expense more than 150 for the month of april
SELECT c.Category, SUM(d.Cost)
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE EXTRACT(MONTH FROM Date) = 4
GROUP BY c.Category
HAVING SUM(d.Cost) > 150;

-- Any patterns in ticket expenses over time
SELECT EXTRACT(MONTH from d.Date) AS Month, SUM(d.Cost)
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Ticket'
GROUP BY Month;

-- Which restaurant has received the maximum orders based on days
SELECT d.Company, COUNT(DISTINCT d.Date) AS Number_of_Orders
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Restaurant'
GROUP BY Company
ORDER BY Number_of_Orders DESC;

-- Calculate average spend for each day for restaurants
SELECT d.Date, AVG(d.Cost) AS Average_Cost
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Restaurant'
GROUP BY d.Date
ORDER BY Average_Cost DESC;

-- Calculate average spend per day for restaurants
SELECT SUM(d.Cost) / COUNT(d.Date)
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Restaurant';

-- Which day of week saw the highest spend in may
SELECT TO_CHAR(Date, 'Day') AS Day_of_Week, SUM(Cost) AS Total_Cost
FROM data
WHERE EXTRACT(MONTH FROM Date) = 5
GROUP BY Day_of_Week
ORDER BY Total_Cost DESC;

-- Calculate total cost for grocery per month
SELECT TO_CHAR(d.Date, 'Month') AS Month, SUM(d.Cost) AS Total_Cost
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Restaurant'
GROUP BY Month
ORDER BY Total_Cost DESC;

-- Calculate total cost for grocery per month and show month in year and month format separated by hyphen
SELECT TO_CHAR(d.Date, 'YYYY-MM') AS Year_Month, SUM(d.Cost) AS Total_Cost
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Restaurant'
GROUP BY Year_Month
ORDER BY Total_Cost DESC;

-- Calculate total spend for each shops starting with capital letter R
SELECT Company, SUM(Cost) as Total_Cost
FROM data
WHERE Company LIKE 'R%'
GROUP BY Company
ORDER BY Total_Cost DESC;

-- Calculate total spend for all shops starting with capital letter R
SELECT SUM(Cost) as Total_Cost
FROM data
WHERE Company LIKE 'R%';

-- How many unique companies exist in the shopping category
SELECT COUNT(DISTINCT Company) AS Unique_Company
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Shopping';

-- What companies exist in the shopping category
SELECT DISTINCT Company
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Shopping';

-- What is the spending pattern at Rewe month wise and any insights
SELECT TO_CHAR(Date, 'Month') AS Month, SUM(Cost) as Total_Cost
FROM data
WHERE Company LIKE 'Rewe'
GROUP BY Month;

-- Any trends with respect to eating at domino's restaurant
SELECT TO_CHAR(Date, 'Month') AS Month, SUM(Cost) as Total_Cost
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Restaurant'
  AND d.Company LIKE 'Dominos'
GROUP BY Month;

-- Is there any month where grocery expense is bit different
SELECT TO_CHAR(Date, 'Month') AS Month, SUM(Cost) as Total_Cost
FROM data d
         JOIN category c ON d.CategoryID = c.CategoryID
WHERE c.Category = 'Grocery'
GROUP BY Month;

-- Show only the company with highest spend in each category for april
WITH RankedCompanies AS (SELECT Company,
                                SUM(d.Cost) AS Total_Cost,
                                c.Category,
                                ROW_NUMBER() OVER (PARTITION BY c.Category ORDER BY SUM(d.Cost) DESC) AS Rank
                         FROM data d
                                  JOIN category c ON d.CategoryID = c.CategoryID
                         WHERE EXTRACT(MONTH FROM d.Date) = 4 -- Filter for April
                         GROUP BY Company, c.Category)
SELECT Company,
       Total_Cost,
       Category,
       Rank
FROM RankedCompanies
WHERE Rank = 1;

-- Calculate % change in total cost for each month & find the month with highest % change
WITH MonthlyCost AS (SELECT EXTRACT(MONTH from Date) AS Month,
                            SUM(Cost)                AS Total_Cost
                     FROM data
                     GROUP BY Month),

     CostChange AS (SELECT Month,
                           Total_Cost,
                           LAG(Total_Cost) OVER (ORDER BY Month) AS Previous_Month_Cost
                    FROM MonthlyCost)

SELECT Month,
       Total_Cost,
       Previous_Month_Cost,
       ((Total_Cost - Previous_Month_Cost) / Previous_Month_Cost) * 100 AS Percentage_Change
FROM CostChange
ORDER BY CostChange.Month;

-- Do the same as above question but only for restaurant category
WITH MonthlyCost AS (SELECT EXTRACT(MONTH from Date) AS Month,
                            SUM(Cost)                AS Total_Cost
                     FROM data d
                              JOIN category c ON d.CategoryID = c.CategoryID
                     WHERE c.Category = 'Restaurant'
                     GROUP BY Month),

     CostChange AS (SELECT Month,
                           Total_Cost,
                           LAG(Total_Cost) OVER (ORDER BY Month) AS Previous_Month_Cost
                    FROM MonthlyCost)

SELECT Month,
       Total_Cost,
       Previous_Month_Cost,
       ((Total_Cost - Previous_Month_Cost) / Previous_Month_Cost) * 100 AS Percentage_Change
FROM CostChange
ORDER BY CostChange.Month;

-- Find the date with highest number of unique categories where money was spent
SELECT Date AS Unique_Date, COUNT(DISTINCT CategoryID) AS Unique_Categories_Count
FROM data
GROUP BY Unique_Date
ORDER BY Unique_Categories_Count DESC;



-- Show the ratio of total spend for restaurants vs grocery for april
WITH AprilExpenses AS (SELECT SUM(CASE
                                      WHEN category.Category = 'Restaurant' THEN expenses_data.Cost
                                      ELSE 0 END) AS Restaurant_Spend,
                              SUM(CASE
                                      WHEN category.Category = 'Grocery' THEN expenses_data.Cost
                                      ELSE 0 END) AS Grocery_Spend
                       FROM data AS expenses_data
                                INNER JOIN
                            category AS category ON expenses_data.CategoryID = category.CategoryID
                       WHERE EXTRACT(MONTH FROM expenses_data.Date) = 4)

SELECT Restaurant_Spend,
       Grocery_Spend,
       CASE
           WHEN Grocery_Spend != 0 THEN Restaurant_Spend / Grocery_Spend
           END AS Spend_Ratio
FROM AprilExpenses;

-- What is the average spend per month at inter store
SELECT Company, AVG(Cost) AS AvgMonth, EXTRACT(MONTH FROM Date) AS Month
FROM data
WHERE Company = 'Inter Store'
GROUP BY Company, Month;


-- which company in shopping category had the highest total cost
SELECT expenses_data.Company AS Company, SUM(expenses_data.Cost) AS Total_Cost
FROM data AS expenses_data
         INNER JOIN category ON expenses_data.CategoryID = category.CategoryID
WHERE category.Category = 'Shopping'
GROUP BY Company
ORDER BY Total_Cost DESC;

-- Use union clause to show total cost for kebab shop and also panda using two different queries
SELECT Company, SUM(Cost) AS AvgMonth
FROM data
WHERE Company = 'Kebab Shop'
GROUP BY Company
UNION ALL
SELECT Company, SUM(Cost) AS AvgMonth
FROM data
WHERE Company = 'Panda'
GROUP BY Company;

-- Is there any fully duplicate value in the data
WITH CTE AS (SELECT *,
                    ROW_NUMBER() OVER (PARTITION BY Date, Company, CategoryID, Cost) AS RowNumber
             FROM data)
SELECT *
FROM CTE
WHERE RowNumber > 1;

