-- The major aim of this project is to gain insight into the sales data of Amazon to understand 
-- the different factors that affect sales of the different branches.

Create database AmazonSalesData;
Create table Sales( invoice_id VARCHAR(30) NOT NULL Primary Key,
	branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_Line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(10,2) NOT NULL,
    rating FLOAT(2,1) );
    
    --------------------- Feature Engineering -------------------------
    
Select 
	time,
	 CASE 
		When time between '00:00:00' and '12:00:00' Then 'Morning'
		When time between '12:01:00' and '16:00:00' Then 'Afternoon'
		Else 'Evening'
	End 
		as time_days
from sales;

Alter table sales add column time_of_day varchar(25);

Update sales
Set time_of_day = (
	CASE 
		When time between '00:00:00' and '12:00:00' Then 'Morning'
		When time between '12:01:00' and '16:00:00' Then 'Afternoon'
		Else 'Evening'
	End );
Select 
	date,
    dayname(date) as day_name
from sales;
    
Alter table sales add column day_name varchar(25);

Update sales
Set day_name = dayname(date);

Select 
	date,
    monthname(date) as month_name
    from sales;
    
Alter table sales add column month_name varchar(25);

Update sales
Set month_name = monthname(date);


---------------------------- EDA ---------------------------------

-- 1. What is the count of distinct cities in the dataset?   * here I found count of unique city
	SELECT 
    COUNT(DISTINCT city) AS city
FROM
    sales;
    
-- 2. For each branch, what is the corresponding city?	* For indiviual city I have to show individual branch here
	SELECT DISTINCT
    city, branch
FROM
    sales; 
    
-- 3. What is the count of distinct product lines in the dataset?	* Found unique product line
	SELECT 
    COUNT(DISTINCT product_line) AS unique_product
FROM
    sales;
    
-- 4. Which payment method occurs most frequently?		* found that particular payment method whose uses is more than other
   SELECT 
    payment_method, COUNT(payment_method) AS payment_count
FROM
    sales
GROUP BY payment_method
ORDER BY payment_count DESC;
    
-- 5. Which product line has the highest sales?		* Show the product line with highest sale
	SELECT 
    product_line, COUNT(product_line) AS highest_sale
FROM
    sales
GROUP BY product_line
ORDER BY highest_sale DESC; 
    
-- 6. How much revenue is generated each month?		* For each month I found the total
	SELECT 
    month_name, SUM(total) AS total_revenue
FROM
    sales
GROUP BY month_name
ORDER BY total_revenue;
    
-- 7. In which month did the cost of goods sold reach its peak?	* Here highest cost of that particular month
	SELECT 
    month_name, SUM(cogs) AS high_cogs
FROM
    sales
GROUP BY month_name
ORDER BY high_cogs DESC
LIMIT 1;
    
-- 8. Which product line generated the highest revenue?		* That product line which has highest sum
	SELECT 
    product_line, SUM(total) AS high_revenue
FROM
    sales
GROUP BY product_line
ORDER BY high_revenue DESC
LIMIT 1;
	
-- 9. In which city was the highest revenue recorded?		* show that particular city with high revenue
	SELECT 
    branch, city, SUM(total) AS total_revenue
FROM
    sales
GROUP BY branch , city
ORDER BY total_revenue DESC
LIMIT 1;
    
-- 10. Which product line incurred the highest Value Added Tax?		* Found highest VAT from 6 unique product line
	SELECT 
    product_line, ROUND(AVG(VAT), 2) AS largest_VAT
FROM
    sales
GROUP BY product_line
ORDER BY largest_VAT DESC
LIMIT 1;
    
-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
	SELECT 
    product_Line,
    ROUND(AVG(total), 2) AS avg_sales,
    CASE
        WHEN
            AVG(total) > (SELECT 
                    AVG(total)
                FROM
                    sales)
        THEN
            'Good'
        ELSE 'Bad'
    END AS Remarks
FROM
    sales
GROUP BY product_line
ORDER BY avg_sales;
            
-- 12. Identify the branch that exceeded the average number of products sold.	* Found that branch which is more than avg product sold
	SELECT 
    branch, SUM(quantity) AS qty
FROM
    sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales);

-- 13. Which product line is most frequently associated with each gender?	* show which gender's sale more in one of that product line
	SELECT 
    gender, product_line, COUNT(gender) AS total_count
FROM
    sales
GROUP BY gender , product_line
ORDER BY total_count DESC;

-- 14. Calculate the average rating for each product line.	* Create avg rating for each product line
	SELECT 
    product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM
    sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- 15. Count the sales occurrences for each time of day on every weekday.	* sales occurance for each day, if we have seen in saturday evening has highest sale
	SELECT 
    time_of_day, COUNT(*) AS total_sales
FROM
    sales
WHERE
    day_name = 'saturday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 16. Identify the customer type contributing the highest revenue.	* found customer type where total revenue is formed
	SELECT 
    customer_type, SUM(total) AS total_revenue
FROM
    sales
GROUP BY customer_type
ORDER BY total_revenue;

-- 17. Determine the city with the highest VAT percentage.	* Found city with high VAT
	SELECT 
    city, ROUND(AVG(VAT), 2) AS high_vat
FROM
    sales
GROUP BY city
ORDER BY high_vat DESC;

-- 18. Identify the customer type with the highest VAT payments.	* Found customer type with high VAT
	SELECT 
    customer_type, ROUND(AVG(VAT), 2) AS high_vat
FROM
    sales
GROUP BY customer_type
ORDER BY high_vat;

-- 19. What is the count of distinct customer types in the dataset?	* Count of unique customer type 
	SELECT 
    COUNT(DISTINCT customer_type) AS unique_customer
FROM
    sales;

-- 20. What is the count of distinct payment methods in the dataset?	* Count of unique payment method
	SELECT 
    COUNT(DISTINCT payment_method) AS unique_payment
FROM
    sales;

-- 21. Which customer type occurs most frequently?	* Found customer type who had more sales
	SELECT 
    customer_type, COUNT(*) AS total_count
FROM
    sales
GROUP BY customer_type
ORDER BY total_count DESC;

-- 22. Identify the customer type with the highest purchase frequency.	* Customer type with high purchase
	SELECT 
    customer_type, COUNT(*) AS customer_count
FROM
    sales
GROUP BY customer_type
ORDER BY customer_count DESC;
        
-- 23. Determine the predominant gender among customers.	* Male member is max than female
	SELECT 
    gender, COUNT(*) AS predominant_gender
FROM
    sales
GROUP BY gender
ORDER BY predominant_gender DESC;
        
-- 24. Examine the distribution of genders within each branch.	* for each branch I have to show gender distribution
	SELECT 
    gender, COUNT(*) AS gender_count
FROM
    sales
WHERE
    branch = 'A'
GROUP BY gender
ORDER BY gender_count;

-- 25. Identify the time of day when customers provide the most ratings.	* Highest rating mention in which day
	 SELECT 
    time_of_day, ROUND(AVG(rating), 2) AS most_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY most_rating DESC;
-- 26. Determine the time of day with the highest customer ratings for each branch. * for each branch I have found rating with day
	SELECT 
    time_of_day, ROUND(AVG(rating), 2) AS high_rating
FROM
    sales
WHERE
    branch = 'A'
GROUP BY time_of_day
ORDER BY high_rating DESC;

-- 27. Identify the day of the week with the highest average ratings. * high rating for week days
	SELECT 
    day_name, ROUND(AVG(rating), 2) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- 28. Determine the day of the week with the highest average ratings for each branch. 
	SELECT 
    day_name, ROUND(AVG(rating), 2) AS high_rating
FROM
    sales
WHERE
    branch = 'C'
GROUP BY day_name
ORDER BY high_rating DESC;


------------------------ Conclusion ----------------------------

-- In this dataset I started to gain valuable insights from Amazon's sales data.
-- I began by preparing and exploring dataset, cleaning any missing or NULL values and engineering new features
-- to help me uncover new meaningful patterns.
-- I have addressed a variety of questions ranging from understanding product performance.
-- These insights are crusial for Amazon's sales strategies and can guide future optimizations.
    
    
    
    
    
    
    
    
    
    