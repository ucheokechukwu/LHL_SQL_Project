--find the products that have the highest searches/views

SELECT products."productSKU", products."productName", COUNT(*)
FROM all_sessions
	INNER JOIN products
	ON products."productSKU"  = all_sessions."productSKU"
GROUP BY products."productSKU", products."productName"
ORDER BY COUNT(*) DESC

--find the dates with the higest traffic

SELECT date, COUNT(*)
FROM all_sessions
GROUP BY date
ORDER BY COUNT(*) DESC

-- find the total number of unique products

SELECT COUNT (*) FROM products;
-- confirming that they're distinct values
SELECT COUNT(DISTINCT "productSKU") FROM products;