--Analyzing all_sessions and analytics
-- Run after cleaning the tables

-- Comparing revenues from all_sessions and analytics
SELECT * FROM analytics
WHERE "fullvisitorId" IN 
			(SELECT "fullVisitorId" FROM all_sessions
			WHERE "totalTransactionRevenue" IS NOT null);
			
SELECT analytics.revenue,
	all_sessions."totalTransactionRevenue"
FROM analytics
INNER JOIN all_sessions
	ON analytics."fullvisitorId" = all_sessions."fullVisitorId"	
WHERE all_sessions."totalTransactionRevenue"  IS NOT null
ORDER BY all_sessions."totalTransactionRevenue", analytics.revenue DESC;

SELECT 	revenue, 
		unit_price * units_sold as calculated_revenue, 
		(unit_price * units_sold)::float/revenue::float as ratio
FROM analytics
WHERE revenue !=0
ORDER BY ratio ;

SELECT MIN(ratio), MAX(ratio), AVG(ratio) FROM
	(SELECT 	revenue, 
		unit_price * units_sold as calculated_revenue, 
		(unit_price * units_sold)::float/revenue::float as ratio
	FROM analytics
	WHERE revenue !=0
	ORDER BY ratio ) as temptable;

--Analyzing Revenue & Unit Price

SELECT analytics.revenue,
	all_sessions."totalTransactionRevenue"
FROM analytics
INNER JOIN all_sessions
	ON analytics."visitId" = all_sessions."visitId"
	
WHERE all_sessions."totalTransactionRevenue"  IS NOT null
AND analytics.revenue IS NOT null
ORDER BY all_sessions."totalTransactionRevenue", analytics.revenue desc;
--54 results


SELECT analytics.revenue,
	all_sessions."totalTransactionRevenue"
FROM analytics
INNER JOIN all_sessions
	ON analytics."fullvisitorId" = all_sessions."fullVisitorId"
	
WHERE all_sessions."totalTransactionRevenue"  IS NOT null
AND analytics.revenue IS NOT null
ORDER BY all_sessions."totalTransactionRevenue", analytics.revenue DESC;

--66 results

