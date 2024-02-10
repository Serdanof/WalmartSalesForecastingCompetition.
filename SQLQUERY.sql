### GitHub Project:  Kaggle Walmart Sales Forecasting Competition.
## SQL Code

## STEP 1
-- -------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------[Data Wrangling]---------------------------------------------------------------------------------
start transaction;
CREATE DATABASE walmartSales;

CREATE TABLE Sales_Data(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch	VARCHAR(5) NOT NULL,
city	VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender	VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price	DECIMAL(10, 2) NOT NULL,
quantity	INT NOT NULL,
VAT	FLOAT(6, 4) NOT NULL,
total	DECIMAL(12, 4) NOT NULL,
date	DATETIME NOT NULL,
time	TIME NOT NULL,
payment_method	VARCHAR(15) NOT NULL,
cogs	DECIMAL(10, 2) NOT NULL,
gross_margin_percentage	FLOAT(11, 9) NOT NULL,
gross_income	DECIMAL(10, 2) NOT NULL,
rating	FLOAT(2, 1) NOT NULL
);

-- -------------------------------------------------------------------------------------------------------------------------------
-- Data used was cleaned AS no NULL values were used 

## STEP 2 
-- -------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------[Feature Engineering ]----------------------------------------------------------------------------
## Create new COLUMNs from existing ones

-- -------------------------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////{START Github Sample}//////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

## For this to work turn off safe mode for UPDATE
## Edit > Preferences > SQL Editor > scroll down and toggle safe mode
## Reconnect to MySQL: Query > Reconnect to server

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END);

-- -------------------------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////////////{END Github Sample}////////////////////////////////////////////////////////////////////

## 2.1 											  	 QUESTION
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(ADD a new COLUMN named time_of_day to give insight of sales in the Morning, Afternoon 
	-- and Evening. This will help answer the question on which part of the day most sales are made.)////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------

select time from sales_data:

-- Here we want to make it eASier to identify the time of day so Morning,Afternoon or Evening and then analyse to check which
-- part of the day the most sales take place 

ALTER TABLE sales_data 
ADD COLUMN   time_of_day  VARCHAR(11);

-- -------------------------------------------------------------------------------------------------------------------------------
## After creating the new COLUMN we populate it so that if time is before 12:00:00 then we enter AM else we put PM
-- -------------------------------------------------------------------------------------------------------------------------------

UPDATE sales_data 
SET time_of_day = "AM"
WHERE  time < '11:59:00';

UPDATE sales_data 
SET time_of_day = "PM"
WHERE  time > '11:59:00';

-- -------------------------------------------------------------------------------------------------------------------------------
## After creating the new COLUMN we populate it so that if time is before 12:00:00 then we enter Morning else if the time is 
	-- before 16:00:00 but after 12:00:00 else we put Afternoon else if time is after 16:00:00 then we enter Morning
-- -------------------------------------------------------------------------------------------------------------------------------

UPDATE sales_data
SET time_of_day = "Morning"
WHERE time <= "12:00:00";

UPDATE sales_data
SET time_of_day = "Afternoon"
WHERE time > "12:00:00" and time <="16:00:00";

UPDATE sales_data
SET time_of_day = "Evening"
WHERE time > "16:00:00";

Answer to 2.1
SELECT time_of_day, COUNT(*) 
FROM sales_data
GROUP BY time_of_day;

-- -------------------------------------------------------------------------------------------------------------------------------
## 2.1.1
## ANSWER :
-- -------------------------------------------------------------------------------------------------------------------------------
## The highest amount of sales according to data take place in Evening with total of 429 sales, then there is Afternoon
	-- coming in second place with 376 total invoices and lAStly Morning with total of 190 invoices
		-- this is if the sales means the number of invoices

## Below is the code showing the results
-- -------------------------------------------------------------------------------------------------------------------------------

SELECT time_of_day, sum(total) 
FROM sales_data
GROUP BY time_of_day;

-- -------------------------------------------------------------------------------------------------------------------------------
## If the sales means the total price that time of the day
	-- them the answer is  Evening 137365.2735 then afternoon 122276.6055 then Morning 61244.5155
-- -------------------------------------------------------------------------------------------------------------------------------


SELECT * FROM sales_data;
-- -------------------------------------------------------------------------------------------------------------------------------

## 2.2												 QUESTION
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(ADD a new COLUMN named day_name that contains the extracted days of the week on which the 
	-- given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each
		-- branch is busiest.)/////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------

## To get the DAYNAME what we can do is use the DAYNAME function then

ALTER TABLE sales_data
ADD COLUMN day_name varchar(10);

select DAYNAME(date) from sales_data;

## This part will populate the table using the aggregate function
UPDATE sales_data
SET day_name = DAYNAME(date)

-- -------------------------------------------------------------------------------------------------------------------------------
## 2.2.1
### Answer
-- -------------------------------------------------------------------------------------------------------------------------------
## Because we cant GROUP BY 2 different COLUMNs we can first create 3 
## tables where each only displays all the information about each,then from 
## from each table we COUNT total invoices then group them by weekday
## hence the answer was for branch A=Sunday ####for branch B=Saturday ####for branch C= is both Tuesday and Saturday

-- -------------------------------------------------------------------------------------------------------------------------------
## Here is the code for branch A
-- -------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM (SELECT b.day_name, COUNT(*) AS abc 
FROM (SELECT * FROM sales_data
WHERE branch = "A") AS b
GROUP BY b.day_name

HAVING abc = (SELECT MAX(c.abc)
FROM (SELECT b.day_name, COUNT(*) AS abc 
FROM (SELECT * FROM sales_data
WHERE branch = "A") AS b
GROUP BY b.day_name) AS c)) AS busiest_day_branch_a;

-- -------------------------------------------------------------------------------------------------------------------------------
## Here is the code for branch B
-- -------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM (SELECT d.day_name, COUNT(*) AS def
FROM (SELECT * FROM sales_data
WHERE branch = "B") AS d
GROUP BY d.day_name

HAVING def = (SELECT MAX(e.def)
FROM (SELECT d.day_name, COUNT(*) AS def 
FROM (SELECT * FROM sales_data
WHERE branch = "B") AS d
GROUP BY d.day_name) AS e)) AS busiest_day_branch_B;


-- -------------------------------------------------------------------------------------------------------------------------------
## Here is the code for branch C
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT day_name, COUNT(*) AS sales_count
FROM sales_data
WHERE branch = 'C'
GROUP BY day_name

HAVING sales_count = (SELECT MAX(sales_count)
FROM (SELECT day_name, COUNT(*) AS sales_count
FROM sales_data
WHERE branch = 'C'
GROUP BY day_name) AS busiest_day_branch_c);

-- -------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM sales_data;
-- -------------------------------------------------------------------------------------------------------------------------------

## 2.3															 QUESTION
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(ADD a new COLUMN named month_name that contains the extracted months of the year on which the 
	-- given transaction took place (Jan, Feb, Mar). Help determine which month of the year hAS the most sales and profit.)///////
-- -------------------------------------------------------------------------------------------------------------------------------

-- To get the DAYNAME what we can do is use the MONTHNAME function then
ALTER TABLE sales_data
ADD COLUMN month_name varchar(12);

SELECT MONTHNAME(date) from sales_data;


## This part will populate the table using the aggregate function
UPDATE sales_data
SET month_name = MONTHNAME(date);

-- -------------------------------------------------------------------------------------------------------------------------------
## 2.3.1
## Answer
-- -------------------------------------------------------------------------------------------------------------------------------
## First we will need to find the month of the year with most sales then
	-- we can find the month with highest profit
		-- in terms of sales the month with highest sales is January(116291.87$),followed
			-- by March(108867.15$) and lAStly February(95727.38$)

## While in terms of profit/gross income the month with the highest is 
	-- January(5537.95$),followed by March(5184.38$) and lastly 
		-- February(4558.65$)

## Code for total sales per month
SELECT month_name, SUM(total) AS total_sales
FROM sales_data
GROUP BY month_name

-- -------------------------------------------------------------------------------------------------------------------------------
## This is the code to order the total sales in descending order, then limits the output, to the greatest value which would be the 
	-- month with th max sales
    
ORDER BY total_sales DESC
LIMIT 1;


## This is the code to find the highest total profit per month
SELECT month_name, SUM(gross_income) AS total_profit_per_month
FROM sales_data
GROUP BY month_name

## This is the code to order the total profit in descending order, then limits the output, to the greatest value which would be the 
	-- month with th max salesprofit
ORDER BY total_profit_per_month DESC
LIMIT 1;

-- -------------------------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////////////{START AI Provided Solution}////////////////////////////////////////////////////////////////////
SELECT month_name, total_profit_per_month
FROM (
    SELECT month_name, SUM(gross_income) AS total_profit_per_month
    FROM sales_data
    GROUP BY month_name
) AS monthly_profits
ORDER BY total_profit_per_month DESC

-- -------------------------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////////////{END AI Provided Solution}////////////////////////////////////////////////////////////////////

-- -------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM sales_data;

## STEP 3 
-- -------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------[Exploratory Data Analysis (EDA]-------------------------------------------------------------
## Answer the listed questions and aims 


-- -------------------------------------------------------------------------------------------------------------------------------
## 3.1 Generic Question
-- -------------------------------------------------------------------------------------------------------------------------------
## 3.1.1
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(How many unique cities does the data have?)///////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT city
FROM sales_data
GROUP BY city;

## 3.1.2
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(In which city is each branch?)////////////////////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT city, branch
FROM sales_data
UNION 	
SELECT city, branch
FROM sales_data;

-- -------------------------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////{START Github Sample}//////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SELECT 
	DISTINCT city,
    branch
FROM sales_data;
-- -------------------------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////////////{END Github Sample}////////////////////////////////////////////////////////////////////


-- -------------------------------------------------------------------------------------------------------------------------------
## 3.2 Product Question
-- -------------------------------------------------------------------------------------------------------------------------------
## 3.2.1
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(How many unique product lines does the data have?)////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT
    product_line
FROM
    sales_data
;


## 3.2.2
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What is the most common payment method?)////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------


SELECT payment_method, COUNT(total) AS count_payment_method
FROM sales_data
GROUP BY payment_method

ORDER BY count_payment_method DESC
LIMIT 1;

## 3.2.3
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What is the most selling product line?)/////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------

SELECT product_line, COUNT(total) AS count_product_line
FROM sales_data
GROUP BY product_line

ORDER BY count_product_line DESC
LIMIT 1;

## 3.2.4
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What is the total revenue by month?)////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------


SELECT month_name, SUM(gross_income) AS total_revenue
FROM sales_data
GROUP BY month_name;

## It has been noted that finding the maximum value of an aggregated result, such as total profit per month, requires a subquery 
## or CTE because direct aggregation over grouped data is not supported in a single step.

## 3.2.5
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What month had the largest COGS?)///////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------

SELECT month_name, cogs_count
FROM (
    SELECT month_name, 	COUNT(cogs) AS cogs_count
    FROM sales_data
    GROUP BY month_name
) AS monthly_cogs
ORDER BY cogs_count DESC
LIMIT 1;


## 3.2.6
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What product line had the largest revenue?)/////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT product_line, SUM(gross_income) AS total_product_line_revenue
FROM sales_data
GROUP BY product_line

ORDER BY total_product_line_revenue DESC
LIMIT 1;
 
## 3.2.7
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What is the city with the largest revenue?)/////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT city, SUM(gross_income) AS total_revenue_per_city
FROM sales_data
GROUP BY city

ORDER BY total_revenue_per_city DESC
LIMIT 1;

## 3.2.8
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What product line had the largest VAT?)/////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------

SELECT product_line, SUM(VAT) AS total_product_line_VAT
FROM sales_data
GROUP BY product_line

ORDER BY total_product_line_VAT DESC
LIMIT 1;

## 3.2.9
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(Fetch each product line and add a column to those product line showing "Good", 
	-- "Bad". Good if its greater than average sales)/////////////////////////////////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT
    product_line
FROM
    sales_data;

## Average Calculation 
SELECT AVG(sales_count) AS average_sales_transactions
FROM (
    SELECT COUNT(*) AS sales_count
    FROM sales_data
    GROUP BY product_line
) AS total_sales_per_product_line;


## Condition that checks if the Product_line sales and compares to the average sales both (<) and >() then cretes a view table to 
## that displays the rankings as either "Good" or "Bad"
## Case is used to check for certain conditions before carrying out an operation *similar syntax to Python Code
-- Calculate the overall average number of sales transactions across all product lines
SELECT 
    product_line, 
    COUNT(*) AS sales_transactions,
    CASE 
        WHEN COUNT(*) > (SELECT AVG(sales_count) AS average_sales_transactions
                         FROM (SELECT product_line, COUNT(*) AS sales_count
                               FROM sales_data
                               GROUP BY product_line) AS sales_per_product_line) THEN 'Good'
        ELSE 'Bad'
    END AS product_line_rankings
FROM sales_data
GROUP BY product_line;



## 3.2.10
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(Which branch sold more products than average product sold?)/////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT branch, COUNT(*) AS number_of_sales
FROM sales_data
GROUP BY branch
HAVING COUNT(*) > (
    SELECT AVG(number_of_sales) FROM (
        SELECT branch, COUNT(*) AS number_of_sales
        FROM sales_data
        GROUP BY branch
    ) AS avg_sales_per_branch);

## 3.2.11
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////(What is the most common product line by gender?)////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT gender, MAX(product_line_count) AS max_product_line_count
FROM (
    SELECT gender, product_line, COUNT(*) AS product_line_count
    FROM sales_data
    GROUP BY gender, product_line
) AS subquery
GROUP BY gender;

## It was noted that Aliases only apply to when you have a function/operation 

## 3.2.12
-- -------------------------------------------------------------------------------------------------------------------------------
## //////////////////////////////////////////What is the average rating of each product line?)////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT product_line, 
AVG(rating) AS avg_rating
FROM sales_data
GROUP BY product_line;


-- -------------------------------------------------------------------------------------------------------------------------------
## 3.3 Product Question
-- -------------------------------------------------------------------------------------------------------------------------------
## 3.3.1
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Number of sales made in each time of the day per weekday)/////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT day_name, time, COUNT(*) AS daily_sales_count 
FROM sales_data                                                         
GROUP BY  day_name, time;

## 3.3.2
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which of the customer types brings the most revenue?)/////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT customer_type, MAX(gross_income) AS max_revenue
FROM sales_data
GROUP BY  customer_type
ORDER BY max_revenue DESC ;

## 3.3.3
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which city has the largest tax percent/ VAT (Value Added Tax)?)///////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT city, MAX(VAT) AS max_VAT_city
FROM sales_data
GROUP BY  customer_type
ORDER BY max_VAT_city DESC ;


## 3.3.4
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which customer type pays the most in VAT?)////////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT customer_type, MAX(VAT) AS max_VAT
FROM sales_data
GROUP BY  customer_type
ORDER BY max_VAT DESC 
LIMIT 1;


-- -------------------------------------------------------------------------------------------------------------------------------
## 3.4 Product Question
-- -------------------------------------------------------------------------------------------------------------------------------
## 3.4.1
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(How many unique customer types does the data have?)///////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT
    customer_type
FROM
    sales_data;


## 3.4.2
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(How many unique payment methods does the data have?)//////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT
    payment_method
FROM
    sales_data;


## 3.4.3
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(What is the most common customer type?)///////////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT customer_type, COUNT(*) AS common_customer
FROM sales_data                                                         
GROUP BY customer_type
ORDER BY customer_type ASC	
LIMIT 1;


## 3.4.4
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which customer type buys the most?)///////////////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT 
    customer_type, COUNT(*) AS active_customer
FROM
    sales_data
GROUP BY customer_type
ORDER BY active_customer DESC
LIMIT 1;


## 3.4.5
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(What is the gender of most of the customers?)/////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT gender, COUNT(*) AS gender_count
FROM sales_data                                                         
GROUP BY gender
ORDER BY gender
LIMIT 1;


## 3.4.6
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(What is the gender distribution per branch?)//////////////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT branch, gender, COUNT(*) AS branch_gender_count
FROM sales_data                                                         
GROUP BY branch, gender
ORDER BY branch ASC, branch_gender_count DESC;


## 3.4.7
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which time of the day do customers give most ratings?)//////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT time_of_day, COUNT(rating) AS most_daily_rating
FROM sales_data                                                         
GROUP BY time_of_day
ORDER BY most_daily_rating DESC
LIMIT 1;


## 3.4.8
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which time of the day do customers give most ratings per branch?)/////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT time_of_day, branch, COUNT(rating) AS most_daily_rating
FROM sales_data                                                         
GROUP BY time_of_day, branch
ORDER BY most_daily_rating DESC;


## 3.4.9
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which day of the week has the best avg ratings?)//////////////////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT day_name, AVG(rating) AS avg_rating
FROM sales_data
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;


## 3.4.10
-- -------------------------------------------------------------------------------------------------------------------------------
## ////////////////////////////////(Which day of the week has the best average ratings per branch?)///////////////////////////////
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT day_name, branch, AVG(rating) AS avg_rating
FROM sales_data
GROUP BY day_name, branch
ORDER BY avg_rating DESC
LIMIT 1;

-- -------------------------------------------------------------------------------------------------------------------------------
COMMIT;

SELECT * FROM sales_data;

