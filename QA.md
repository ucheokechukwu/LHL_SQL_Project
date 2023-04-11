What are your risk areas? Identify and describe them.

**Incomplete data**. Several instances had incomplete or null values which might have been mistakes, wrong entries or supposed to indicate 0 (e.g. units sold). I had to make assumptions about what they meant which may/may not have been correct, which in turn could skew the results given. 
**Insufficient information** about the meaning of the different data, and their function meant that I didn't have a proper understanding of what the values represented and which values were dependent or derived from other values. e.g.. I set revenue as unit price * units sold where Revenue is null in Analytics, assuming that it was missing data. But perhaps Revenue is null was supposed to mean Revenue = 0 and the visitor visited the site without completing an order?



QA Process:
Describe your QA process and include the SQL queries used to execute it.

-- QA for queries about revenue.
-- Derive the sum total of the revenues recorded


--QA for revenue questions
-- will return TRUE as long as total revenue in each query is less than the total value above

WITH q1_table AS 
	(SELECT country, city, SUM(revenue) AS sumrevenue
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
	FROM q1_table)) AS test
FROM analytics
	;
	-- returns True to pass
	
----

WITH q1_table AS 
	(SELECT country, SUM(revenue) AS sumrevenue
	FROM analytics
		INNER JOIN visitorLocation
		ON analytics."visitId" = visitorLocation."visitId"

	GROUP BY country
	ORDER BY sum(revenue) DESC)

SELECT 
	DISTINCT ((SELECT SUM(revenue) 
	FROM analytics )
	>
	(SELECT SUM(sumrevenue) 
	FROM q1_table)) AS test
FROM analytics
	;
-- returns True to pass

-- Average units sold per country must be equivalent to average units sold across row


-- QA for new products table
-- Adding up the unique values of all the SKUs in the different tables
WITH skucount AS

    (SELECT DISTINCT("productSKU") FROM all_sessions
    UNION
    SELECT DISTINCT("productSKU") FROM sales_by_sku
    UNION
    SELECT DISTINCT("productSKU") FROM original_products)

SELECT COUNT (DISTINCT ("productSKU")) FROM skucount


--Result is 1246

SELECT COUNT(*) FROM products; --1246
