# Retail Sales Analysis SQL Project

## 📘 Overview

**Project Title**: Retail Sales Analysis   
**Database**: `Project_1`

This project focuses on applying core SQL skills to explore, clean, and analyze retail sales data.
You’ll create a retail sales database, perform exploratory data analysis (EDA), and use SQL queries to extract meaningful business insights.

It’s an ideal hands-on project for beginners who want to gain real-world data analysis experience using SQL.

## 🎯 Project Goals

1. **Database Setup**: Build and populate a SQL database to store retail transaction data.
2. **Data Cleaning**: Identify and handle missing or invalid entries to ensure clean, reliable data.
3. **Exploratory Data Analysis (EDA)**: Explore trends, patterns, and key metrics such as sales volume, customer demographics, and category performance.
4. **Business Insights**: Write SQL queries to answer specific business questions — for example:

• Which month had the highest average sales?

• Which product categories are most profitable?

• How many unique customers made purchases?

## 🧱 Project Structure

### 1️⃣ Database Setup

- **Database Creation**: The project starts by creating a database named `Projec_1`. 
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE Project_1;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift
```

📊 Findings
🧍‍♂️ Customer Demographics
The dataset captures a diverse range of customers from different age groups. Sales are distributed across multiple product categories such as Clothing, Beauty, and Electronics, reflecting a varied customer base.
💰 High-Value Transactions
Several transactions recorded total sales above 1,000, highlighting instances of premium purchases and potential high-value customers.
📅 Sales Trends
Monthly analysis revealed noticeable fluctuations in sales volume, helping identify peak months and seasonal demand patterns.
👑 Customer Insights
The analysis also uncovered the top-spending customers and most popular product categories, offering valuable insights for marketing and inventory decisions.

📈 Reports Generated
1️⃣ Sales Summary
A comprehensive overview of total sales, customer demographics, and product category performance.
2️⃣ Trend Analysis
Detailed visualization and SQL results showing monthly sales patterns and time-based performance variations.
3️⃣ Customer Insights
Focused reports identifying loyal customers, unique buyers per category, and purchase frequency trends.

🧩 Conclusion
This project provides a complete hands-on introduction to SQL for aspiring data analysts.
It covers every essential step — from database setup and data cleaning to exploratory data analysis (EDA) and business-focused SQL reporting.
The insights generated from this project can support data-driven decision-making, especially in understanding:
• Customer purchasing behavior
• Seasonal sales performance
• Product profitability

⚙️ How to Use
• Clone the Repository
Download or clone this project from GitHub using:

o git clone <repository_link>

• Set Up the Database
Execute the SQL script named sql_query_p1.sql to create and populate the database (Project_1).

• Run the Analysis Queries
Use the provided sql_query_p1.sql file to perform data cleaning, EDA, and business analysis.

• Explore Further
Modify the queries or add your own to explore new questions — such as identifying repeat customers, product performance by age group, or time-of-day sales patterns. sql_query_p1


