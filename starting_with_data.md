--Question 1: find the products that have the highest searches/views

SELECT products."productSKU", products."productName", COUNT(*)
FROM all_sessions
    INNER JOIN products
    ON products."productSKU" = all_sessions."productSKU"
GROUP BY products."productSKU", products."productName"
ORDER BY COUNT(*) DESC

-- Question 2-4: find information about time e.g. the time periods with the highest traffic

SELECT EXTRACT(YEAR FROM date), 
		EXTRACT(MONTH FROM date), 
		COUNT(*)
FROM all_sessions
GROUP BY EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date)
ORDER BY COUNT(*) DESC;
-- 2016 August and September have the highest traffic

SELECT EXTRACT(MONTH FROM date), 
		COUNT(*)
FROM all_sessions
GROUP BY EXTRACT(MONTH FROM date)
ORDER BY COUNT(*) DESC;
-- The months with the most traffic are August and September
-- Might make sense if the store supplies a lot of stationary equipment


SELECT EXTRACT(YEAR FROM date), 
		EXTRACT(MONTH FROM date), 
		SUM(revenue)
FROM analytics
GROUP BY EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date)
ORDER BY SUM(revenue) DESC;
-- July August 2017



--Question 4: find the total number of unique products

-- SQL Queries: 
-- see notes in cleaning_data.md about creating new products table
SELECT COUNT (*) FROM products

-- Answer: 1246 unique products