-- Question 1:  Which year had the highest total retail sales?
SELECT TOP 1 YEAR, SUM(RETAIL_SALES) AS Total_Retail_Sales 
FROM Warehouse_and_Retail_Sales
GROUP BY YEAR
ORDER BY Total_Retail_Sales DESC;

-- Question 2: Who are the top 5 suppliers in terms of retail sales?
SELECT TOP 5 SUPPLIER
FROM Warehouse_and_Retail_Sales
GROUP BY SUPPLIER
ORDER BY SUM(RETAIL_SALES) DESC;

-- Question 3: Retrieve all data from the year 2019 during month 10.
SELECT *
FROM Warehouse_and_Retail_Sales
WHERE YEAR = 2019 AND MONTH = 10;

-- Question 4: Find the month with the highest retail sales for each year.
WITH total AS (
	SELECT YEAR, MONTH, SUM(RETAIL_SALES) AS total_sales, RANK() OVER(PARTITION BY YEAR ORDER BY SUM(RETAIL_SALES) DESC) AS sales_rank
	FROM Warehouse_and_Retail_Sales
	GROUP BY YEAR, MONTH)

SELECT YEAR, MONTH 
FROM total
WHERE sales_rank = 1;

-- Question 5: Segment suppliers into categories based on their sales behavior and performance.
WITH total_sales AS (
	SELECT SUPPLIER, SUM(RETAIL_SALES) + SUM(WAREHOUSE_SALES) AS total_retail_warehouse_sales
	FROM Warehouse_and_Retail_Sales
	GROUP BY SUPPLIER)

SELECT SUPPLIER, total_retail_warehouse_sales,
CASE
	WHEN total_retail_warehouse_sales >= 10000 THEN 'High Sales'
	WHEN total_retail_warehouse_sales >= 1000 THEN 'Average Sales'
	ELSE 'Low Sales'
END AS supplier_performance
FROM total_sales;

-- Question 6: Calculate the growth rate in retail sales for 2018 - 2020.

WITH yearly_sales AS (
	SELECT YEAR, SUM(RETAIL_SALES) as total_sales
	FROM Warehouse_and_Retail_Sales
	GROUP BY YEAR),

	yearly_growth AS ( 
	SELECT t1.YEAR, t1.total_sales AS current_year_sales, t2.total_sales AS prev_year_sales,
	((t1.total_sales - t2.total_sales) / t2.total_sales) * 100 AS growth_rate
	FROM yearly_sales t1 JOIN yearly_sales t2 ON t1.YEAR = t2.YEAR + 1)

SELECT * FROM yearly_growth
ORDER BY YEAR;

-- Question 7: Calculate the year-over-year growth in retail sales for each supplier.
WITH total AS (
	SELECT YEAR, SUPPLIER, SUM(RETAIL_SALES) AS total_sales
	FROM Warehouse_and_Retail_Sales
	WHERE SUPPLIER IS NOT NULL
	GROUP BY YEAR, SUPPLIER)

SELECT YEAR, SUPPLIER, total_sales,
LAG(total_sales) OVER (PARTITION BY SUPPLIER ORDER BY YEAR) AS prev_year_sales,
CASE
	WHEN
	LAG(total_sales) OVER (PARTITION BY SUPPLIER ORDER BY YEAR) IS NOT NULL AND LAG(total_sales) OVER (PARTITION BY SUPPLIER ORDER BY YEAR) <> 0
    THEN (total_sales - LAG(total_sales) OVER (PARTITION BY SUPPLIER ORDER BY YEAR)) / (LAG(total_sales) OVER (PARTITION BY SUPPLIER ORDER BY YEAR)) * 100
    ELSE NULL
END AS year_over_year
FROM total
ORDER BY SUPPLIER, YEAR;