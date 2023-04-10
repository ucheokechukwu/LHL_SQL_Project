Question 1: find the products that have the highest searches/views

SQL Queries: SELECT products."productSKU", products."productName", COUNT(*)
FROM all_sessions
	INNER JOIN products
	ON products."productSKU"  = all_sessions."productSKU"
GROUP BY products."productSKU", products."productName"
ORDER BY COUNT(*) DESC

Answer: SKU - GGOEGAAX0104
Name -  Men's 100% Cotton Short Sleeve Hero Tee White\
Count - 284



Question 2: find the dates with the higest traffic

SQL Queries: --find the dates with the higest traffic

SELECT date, COUNT(*)
FROM all_sessions
GROUP BY date
ORDER BY COUNT(*) DESC

Answer: 2016-08-15
Count 106



Question 3: find the total number of unique products

SQL Queries: 
-- see notes in cleaning_data.md about creating new products table
alter table products
add primary key ("productSKU")

Answer: 1246 unique products



Question 4: 

SQL Queries:

Answer:



Question 5: 

SQL Queries:

Answer:
