# Use retail_sales_db schema
USE retail_sales_db;

# Create table with field type
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
	transactions_id INT PRIMARY KEY,
	sale_date DATE NOT NULL,
	sale_time TIME NOT NULL,
	customer_id INT NOT NULL,
	gender ENUM('Male','Female'),
	age	INT,
    -- Can check the length of the character by using this formula in Excel [=MAX(LEN()]
    category VARCHAR (15),
	quantity INT,
    price_per_unit DECIMAL(10,2),
	cogs DECIMAL(10,2),
	total_sale DECIMAL(10,2) 
    );
    
# Check the table
SELECT * FROM retail_sales;

# My Analysis & Findings
-- Q1 Write a SQL query to retriew all column for sale made on '2022-11-05'.
SELECT * FROM retail_sales
WHERE sale_date = "2022-11-05";

-- Q2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than equal to 4 in the month of Nov-2022.
SELECT * FROM retail_sales
WHERE category = "Clothing" 
AND quantity >= 4 
# Make sure the range is between (the highest) and (the lowest)
AND sale_date BETWEEN "2022-11-31" AND "2022-11-01";

-- Q3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT 
	category,
	SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY category;

-- Q4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT 
	ROUND(AVG(age),0) AS avg_age
FROM retail_sales 
WHERE category = "Beauty";

-- Q5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q6 Write a SQL query to find the total number of transactions (transactions_id) made by each gender in each category.
SELECT 
	gender,
    category,
	COUNT(transactions_id) AS num_of_transaction
FROM retail_sales 
# Any column in SELECT that is NOT inside an aggregate function must appear in GROUP BY 
GROUP BY gender, category
ORDER BY num_of_transaction DESC;

-- Q7 Write a SQL query to calculate the average sale for each month. Find out the best selling month in each year.
SELECT * FROM
(
	SELECT 
		MONTH(sale_date) AS month,
		YEAR(sale_date) AS year,
		ROUND(AVG(total_sale),2) AS avg_sales,
		RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS ranking
	FROM retail_sales
	GROUP BY month, year
) AS t1
WHERE ranking = 1;

# Alternative method (using extract function)
SELECT * FROM
(
	SELECT 
		EXTRACT(MONTH FROM sale_date) AS month,
		EXTRACT(YEAR FROM sale_date) AS year,
		ROUND(AVG(total_sale),2) AS avg_sales,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS ranking
	FROM retail_sales
	GROUP BY month, year
) AS t1
WHERE ranking = 1;

-- Q8 Write a SQL query to find the top 5 customer based on the highest total sales.
SELECT 
	customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT 
	category,
	COUNT(DISTINCT customer_id) AS num_of_unique_cust
FROM retail_sales
GROUP BY category;

-- Q10 Write a SQL query to create each shift and number of orders (Example Morning <= 12, Afternoon Between 12 & 17, Evening > 17)
# Use CASE statement for this query for the logic given
SELECT 
	CASE
		WHEN HOUR(sale_time) < 12 THEN "Morning"
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN "Afternoon"
        ELSE "Evening"
	END AS shift,
    COUNT(transactions_id) AS num_of_order
FROM retail_sales
GROUP BY shift;

# Alternative method (Make it as subquery and use extract function)
SELECT
    CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN "Morning"
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN "Afternoon"
        ELSE "Evening"
	END AS shift,
    COUNT(transactions_id) AS num_of_orders
FROM retail_sales
GROUP BY shift;