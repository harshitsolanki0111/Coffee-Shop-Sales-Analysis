-- We are creating a database named coffee_shop for the coffee shop sales analysis.
drop database if exists coffee_shop_sales_db;
CREATE DATABASE coffee_shop_sales_db;     -- Database created 
use coffee_shop_sales_db;   -- working on database after importing data 
select * from `coffee shop`; -- To veiw my data 
select count(*) from `coffee shop`; -- To counting rows in our data 
describe `coffee shop`;  -- To check datatypes or null values 
-- THERE ARE NULL VALUES AND INCORRECT DATATYPES NOW WE ARE PERFORMING DATA CLEANING

-- updating the datatype of transaction_date column (text to DATE)
select * from `coffee shop`;
update `coffee shop`
set transaction_date = str_to_date(transaction_date, '%m/%d/%Y')
where transaction_date is not null;  -- There are null values so we are using WHERE clause

alter table `coffee shop`
modify column transaction_date date;
describe `coffee shop`;

-- updating the datatype of transaction_time column (text to TIME)
select * from `coffee shop`;
UPDATE `coffee shop`
SET transaction_time = STR_TO_DATE(transaction_time,'%h:%i:%s %p')
WHERE transaction_date IS NOT NULL; 

alter table `coffee shop`
modify column transaction_time time;
describe `coffee shop`;

-- TOTAL SALES ANALYSIS 
select * from `coffee shop`;

-- Calculate total sales for each respective month
SELECT ROUND(SUM(unit_price * transaction_qty)) as Total_sales
from `coffee shop`
WHERE MONTH (transaction_date) = 3;  -- MARCH month sales, we can change the number 3 to any month number like if we put 1 we'll get sales for JANUARY 

-- -- Calculating the difference in sales btw the selected month and previous month and month on month increase or decrease in sales

 /* For finding the total sales difference what we are doing is Substacting the
   sum of Selected Month(SM) and sum of Previous Month(PM)....and dividing it by the sum of Previous Month
   and multiplying it with 100 to get the Percentage.
          SUM(SM) - SUM(PM)/ SUM(PM) * 100 
   So here we used some advanced windows function LAG() and OVER() */
   
SELECT 
      MONTH(transaction_date) as Month, -- Number of Month
      ROUND(SUM(unit_price * transaction_qty)) as Total_Sales, -- Total sales 
      SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1) -- Months sales difference
      OVER(ORDER BY MONTH(transaction_date))/ LAG(SUM(unit_price * transaction_qty),1) -- Dividing by previous month
      OVER(ORDER BY MONTH(transaction_date)) * 100 as mom_increase_percentage -- Percentage
FROM `coffee shop`
WHERE 
      MONTH(transaction_date) IN (2,3) -- For months of February(PM) and March(SM)
GROUP BY 
	  MONTH(transaction_date)
ORDER BY 
      MONTH(transaction_date);
      
-- Total order analysis 
select * from `coffee shop`;

-- Calculating total no of orders for each respective month
select count(transaction_id) as Total_orders
from `coffee shop`
where month (transaction_date) = 3; -- march orders 

-- calculating the difference in orders month on month increase or decrease in orders 

/* For finding the total order difference what we are doing is Substacting the
   count of Selected Month(SM) and count of Previous Month(PM)....and dividing it by the count of Previous Month
   and multiplying it with 100 to get the Percentage.
          COUNT(SM) - COUNT(PM)/ COUNT(PM) * 100 
 */
SELECT 
      MONTH(transaction_date) as Month, -- Number of Month
      ROUND(COUNT(transaction_id)) as Total_Orders, -- Total Orders
      COUNT(transaction_id) - LAG(COUNT(transaction_id),1) -- Months Order difference
      OVER(ORDER BY MONTH(transaction_date))/ LAG(COUNT(transaction_id),1) -- Dividing by previous month
      OVER(ORDER BY MONTH(transaction_date)) * 100 as mom_increase_percentage -- Percentage
FROM `coffee shop`
WHERE 
      MONTH(transaction_date) IN (2,3) -- For months of February(PM) and March(SM)
GROUP BY 
	  MONTH(transaction_date)
ORDER BY 
      MONTH(transaction_date);
      

-- Total quqntity sold analysis
select * from `coffee shop`;

-- calculating total quantity sold for each respective month
select sum(transaction_qty) as Total_quantity_sold
from `coffee shop`
where month(transaction_date) = 3;  -- March month

-- calculating the difference in quantity sold  month on month increase or decrease in total quantity sold 

 /* For finding the total quantity sold difference what we are doing is Substacting the
   sum of Selected Month(SM) and sum of Previous Month(PM)....and dividing it by the count of Previous Month
   and multiplying it with 100 to get the Percentage.
          SUM(SM) - SUM(PM)/ SUM(PM) * 100 
 */
 
 select
		month(transaction_date) as month, 
        round(sum(transaction_qty)) as Total_quantity_sold,
        (sum(transaction_qty) - lag(sum(transaction_qty),1)
        over(order by month(transaction_date))) / lag(sum(transaction_qty),1)
        over(order by month(transaction_date)) * 100 as mom_increase_percentage -- 
from 
	`coffee shop`
where 
	month(transaction_date) in (2,3)  -- For months of February(PM) and March(SM)
group by
	month(transaction_date)
order by
	month(transaction_date);
    
-- SUMMARIZED MATIX OF SALES,ORDER AND QUANTITY
select * from `coffee shop`;    
select                         -- we have used the concat and round to round off the values upto 1 decimal point and get in a manner like 5.6K
		concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales, 
        concat(round(sum(transaction_qty)/1000,1), 'K') as Total_quantity_sold,
        concat(round(count(transaction_id)/1000,1), 'K') as Total_orders
from `coffee shop`
where transaction_date = '2023-03-27';

-- Sales analysis by weekends and weekdays 

-- Weekends - Sat,Sun
-- Weekdays - Mon to Fri
select        -- Sun = 1,Mon=2....Sat=7  that's why we have mentioned 1,7 because it's weekend Sun and Sat
	case when dayofweek(transaction_date) in (1,7) then 'Weekends'
    else 'Weekdays'
    end as Day_type,
    concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales
from `coffee shop`
where month(transaction_date) = 3 -- march month
group by Day_type;


-- Sales analysis by store location 
select * from `coffee shop`;

select 
	store_location,
    concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales 
from `coffee shop`
where month(transaction_date) = 3  -- march month
group by store_location
order by Total_sales desc;

-- Daily sales analysis with average line 

-- 1 Average sales revenue
select 
	concat(round(avg(Total_sales)/1000,1), 'K') as Avg_sales
from
	(select sum(unit_price * transaction_qty) as Total_sales
	from `coffee shop`
    where month(transaction_date) = 3
    group by transaction_date
    ) as inner_query;
    
-- Daily sales revenue 
select day(transaction_date) as Day_of_month,
sum(unit_price * transaction_qty) as Total_sales
from `coffee shop`
where month(transaction_date) = 3
group by day(transaction_date)
order by day(transaction_date);

-- Daily sales analysis with average line 
select 
	Day_of_month,
    case
		when Total_sales > Avg_sales then 'Above Average'
        when Total_sales < Avg_sales then 'Below Average'
        else 'Average'
	end as Sales_status,
    Total_sales
	from (
	select
		day(transaction_date) as Day_of_month,
		sum(unit_price * transaction_qty) as Total_sales,
		avg(unit_price * transaction_qty) over() as Avg_sales
	from 
		`coffee shop`
	where 
		month(transaction_date) = 5  -- filter for may month
	group by 
        day(transaction_date)
) as Sales_data
order by Day_of_month;

SELECT 
    Day_of_month,
    CASE
        WHEN Total_sales > Avg_sales THEN 'Above Average'
        WHEN Total_sales < Avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS Sales_status,
    Total_sales
FROM (
    SELECT
        DAY(transaction_date) AS Day_of_month,
        SUM(unit_price * transaction_qty) AS Total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS Avg_sales
    FROM `coffee shop`
    WHERE MONTH(transaction_date) = 5
    GROUP BY DAY(transaction_date)
) AS Sales_data
ORDER BY Day_of_month;

-- Sales analysis with product category 
select * from `coffee shop`;

select product_category,
concat(round(sum(unit_price * transaction_qty)/1000,1), 'k') as Total_sales 
from `coffee shop`
where month(transaction_date) = 3  -- March month
group by product_category
order by Total_sales desc;

-- Top 10 products by sales 
select product_type,
concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales 
from `coffee shop`
where month(transaction_date) = 3
group by product_type
order by Total_sales desc
limit 10;

-- Sales analysis by days and hours 
select * from `coffee shop`;
select
 concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales,
 sum(transaction_qty) as Total_quantity_sold,
 count(*)
from `coffee shop`
where month(transaction_date) = 3  -- march month
and dayofweek(transaction_date) = 2  -- monday
and hour(transaction_time) = 8;  -- hour no 8

-- 1. To get sales for all hours of the month March
select
	hour(transaction_time),
    concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales
from `coffee shop`
where month(transaction_date)
group by hour(transaction_time)
order by hour(transaction_time);

-- 2. To get the sales from Mon to Sun of the month March

select
case 
	when dayofweek(transaction_date) = 2 then 'Monday'
    when dayofweek(transaction_date) = 3 then 'Tuesday'
    when dayofweek(transaction_date) = 4 then 'Wednesday'
    when dayofweek(transaction_date) = 5 then 'Thursday'
    when dayofweek(transaction_date) = 6 then 'Friday'
    when dayofweek(transaction_date) = 7 then 'Saturday'
    else 'sunday'
end as Day_of_week,
concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales
from `coffee shop`
where month(transaction_date) = 3
group by Day_of_week;