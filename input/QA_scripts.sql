
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


