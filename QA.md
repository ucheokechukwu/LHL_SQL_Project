What are your risk areas? Identify and describe them.

Incomplete data led to me deleting rows that might have valuable information.
Not having information about the meaning of the data, and function meant I had to make assumptions which could be wrong. e.g. I set revenue as unit price * units sold where Revenue is null in Analytics, assuming that it was missing data. But perhaps Revenue is null was supposed to mean Revenue = 0 and the visitor visited the site without completing an order?



QA Process:
Describe your QA process and include the SQL queries used to execute it.

-- QA for queries about revenue.
-- Derive the sum total of the revenues recorded

WITH q1_table AS 
	(SELECT country, city, SUM(revenue) as sumrevenue
	FROM analytics
		INNER JOIN visitorLocation
		ON analytics."visitId" = visitorLocation."visitId"

	GROUP BY country, city
	ORDER BY sum(revenue) DESC)

SELECT 
	DISTINCT ((SELECT SUM(revenue) 
	FROM analytics )
	>
	(SELECT SUM(sumrevenue) 
	FROM q1_table))
FROM analytics
	;



