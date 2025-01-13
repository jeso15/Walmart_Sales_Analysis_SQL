-- Create database
CREATE DATABASE IF NOT EXISTS Walmart_Sales;

-- Create table
CREATE TABLE IF NOT EXISTS Sales (
    InvoiceID VARCHAR(30) NOT NULL PRIMARY KEY,
    BranchCode VARCHAR(5) NOT NULL,
    CityName VARCHAR(30) NOT NULL,
    CustomerCategory VARCHAR(30) NOT NULL,
    Gender VARCHAR(30) NOT NULL,
    ProductCategory VARCHAR(100) NOT NULL,
    UnitCost DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    TaxPercentage FLOAT(6,4) NOT NULL,
    TotalAmount DECIMAL(12,4) NOT NULL,
    TransactionDate DATETIME NOT NULL,
    TransactionTime TIME NOT NULL,
    PaymentMethod VARCHAR(15) NOT NULL,
    CostOfGoodsSold DECIMAL(10,2) NOT NULL,
    GrossMarginPercentage FLOAT(11,9),
    GrossIncome DECIMAL(12,4),
    CustomerRating FLOAT(2,1)
);

-- Verify data
SELECT * FROM Sales;

-- Add a column for time of day
SELECT 
    TransactionTime,
    CASE
        WHEN TransactionTime BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN TransactionTime BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS TimeOfDay
FROM Sales;

ALTER TABLE Sales ADD COLUMN TimeOfDay VARCHAR(20);

UPDATE Sales
SET TimeOfDay = CASE
    WHEN TransactionTime BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
    WHEN TransactionTime BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- Add a column for day name
SELECT 
    TransactionDate,
    DAYNAME(TransactionDate) AS DayOfWeek
FROM Sales;

ALTER TABLE Sales ADD COLUMN DayOfWeek VARCHAR(10);

UPDATE Sales
SET DayOfWeek = DAYNAME(TransactionDate);

-- Add a column for month name
SELECT 
    TransactionDate,
    MONTHNAME(TransactionDate) AS MonthName
FROM Sales;

ALTER TABLE Sales ADD COLUMN MonthName VARCHAR(10);

UPDATE Sales
SET MonthName = MONTHNAME(TransactionDate);

-- ------------------------------------------------------------
-- --------------------- Generic Queries ---------------------
-- ------------------------------------------------------------

-- Count unique cities
SELECT DISTINCT CityName FROM Sales;

-- Find branch location per city
SELECT DISTINCT CityName, BranchCode FROM Sales;

-- ------------------------------------------------------------
-- --------------------- Product Analysis --------------------
-- ------------------------------------------------------------

-- Count distinct product categories
SELECT DISTINCT ProductCategory FROM Sales;

-- Identify top-selling product category
SELECT 
    ProductCategory, 
    SUM(Quantity) AS TotalQuantity
FROM Sales
GROUP BY ProductCategory
ORDER BY TotalQuantity DESC;

-- Calculate total revenue by month
SELECT 
    MonthName, 
    SUM(TotalAmount) AS Revenue
FROM Sales
GROUP BY MonthName
ORDER BY Revenue DESC;

-- Month with the highest COGS
SELECT 
    MonthName, 
    SUM(CostOfGoodsSold) AS TotalCOGS
FROM Sales
GROUP BY MonthName
ORDER BY TotalCOGS DESC;

-- Product category with highest revenue
SELECT 
    ProductCategory, 
    SUM(TotalAmount) AS Revenue
FROM Sales
GROUP BY ProductCategory
ORDER BY Revenue DESC;

-- City generating the highest revenue
SELECT 
    CityName, 
    BranchCode, 
    SUM(TotalAmount) AS Revenue
FROM Sales
GROUP BY CityName, BranchCode
ORDER BY Revenue DESC;

-- Product category with highest average VAT
SELECT 
    ProductCategory, 
    AVG(TaxPercentage) AS AvgTax
FROM Sales
GROUP BY ProductCategory
ORDER BY AvgTax DESC;

-- Evaluate product categories as "Good" or "Bad" based on sales
SELECT 
    ProductCategory,
    CASE
        WHEN AVG(Quantity) > (SELECT AVG(Quantity) FROM Sales) THEN 'Good'
        ELSE 'Bad'
    END AS Performance
FROM Sales
GROUP BY ProductCategory;

-- Branch performance above average product sales
SELECT 
    BranchCode, 
    SUM(Quantity) AS TotalQuantity
FROM Sales
GROUP BY BranchCode
HAVING SUM(Quantity) > (SELECT AVG(Quantity) FROM Sales);

-- Analyze product popularity by gender
SELECT 
    Gender, 
    ProductCategory, 
    COUNT(*) AS Count
FROM Sales
GROUP BY Gender, ProductCategory
ORDER BY Count DESC;

-- Average rating per product category
SELECT 
    ProductCategory, 
    ROUND(AVG(CustomerRating), 2) AS AvgRating
FROM Sales
GROUP BY ProductCategory
ORDER BY AvgRating DESC;

-- ------------------------------------------------------------
-- ------------------- Customer Insights ---------------------
-- ------------------------------------------------------------

-- Distinct customer types
SELECT DISTINCT CustomerCategory FROM Sales;

-- Popular payment methods
SELECT DISTINCT PaymentMethod FROM Sales;

-- Most common customer category
SELECT 
    CustomerCategory, 
    COUNT(*) AS Count
FROM Sales
GROUP BY CustomerCategory
ORDER BY Count DESC;

-- Customer category with the most transactions
SELECT 
    CustomerCategory, 
    COUNT(*) AS TransactionCount
FROM Sales
GROUP BY CustomerCategory;

-- Gender distribution
SELECT 
    Gender, 
    COUNT(*) AS Count
FROM Sales
GROUP BY Gender;

-- Analyze customer gender per branch
SELECT 
    Gender, 
    COUNT(*) AS Count
FROM Sales
WHERE BranchCode = 'C'
GROUP BY Gender;

-- Customer ratings based on time of day
SELECT 
    TimeOfDay, 
    AVG(CustomerRating) AS AvgRating
FROM Sales
GROUP BY TimeOfDay;

-- Ratings by day of the week
SELECT 
    DayOfWeek, 
    AVG(CustomerRating) AS AvgRating
FROM Sales
GROUP BY DayOfWeek
ORDER BY AvgRating DESC;

-- ------------------------------------------------------------
-- -------------------- Sales Analysis -----------------------
-- ------------------------------------------------------------

-- Sales by time of day on a specific day
SELECT 
    TimeOfDay, 
    COUNT(*) AS SalesCount
FROM Sales
WHERE DayOfWeek = 'Sunday'
GROUP BY TimeOfDay
ORDER BY SalesCount DESC;

-- Revenue contribution by customer type
SELECT 
    CustomerCategory, 
    SUM(TotalAmount) AS Revenue
FROM Sales
GROUP BY CustomerCategory
ORDER BY Revenue DESC;

-- City with highest average VAT
SELECT 
    CityName, 
    ROUND(AVG(TaxPercentage), 2) AS AvgVAT
FROM Sales
GROUP BY CityName
ORDER BY AvgVAT DESC;

-- Customer type with highest VAT contribution
SELECT 
    CustomerCategory, 
    AVG(TaxPercentage) AS AvgVAT
FROM Sales
GROUP BY CustomerCategory
ORDER BY AvgVAT DESC;
