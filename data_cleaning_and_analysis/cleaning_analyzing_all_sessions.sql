DROP TABLE all_sessions; --checkpoint
CREATE TABLE all_sessions as table original_all_sessions;

-- reviewing with excel, removing the following:
-- productrefundAmount - all blanks
-- pageTitle is redundant with an v2ProductName
-- transactions - only 1 row has any data.
-- itemQuantity (empty)
-- itemRevenue (empty)
-- searchKeyWord (empty)
-- product Variant (would be great for the products table)
-- updating price by /1,000,000

ALTER TABLE all_sessions
DROP COLUMN "productRefundAmount";
ALTER TABLE all_sessions
DROP COLUMN "pageTitle";
ALTER TABLE all_sessions
DROP COLUMN "transactions";
ALTER TABLE all_sessions
DROP COLUMN "itemQuantity";
ALTER TABLE all_sessions
DROP COLUMN "itemRevenue";
ALTER TABLE all_sessions
DROP COLUMN "searchKeyword";
ALTER TABLE all_sessions
DROP COLUMN "currencyCode";
UPDATE all_sessions
SET "totalTransactionRevenue" = "totalTransactionRevenue"::float/1000000;
UPDATE all_sessions
SET "productPrice" = "productPrice"::float/1000000;

-- select * from all_sessions
-- where "transactionRevenue" !=0;

SELECT "fullVisitorId", COUNT("fullVisitorId") FROM all_sessions
GROUP BY "fullVisitorId"
ORDER BY COUNT ("fullVisitorId") DESC;

SELECT "country", COUNT(*) FROM all_sessions
GROUP BY "country"
ORDER BY COUNT(*) DESC;
-- 24 rows have 'not set'
-- check the city
SELECT "country", "city", COUNT(*) FROM all_sessions
WHERE "country" = '(not set)'
GROUP BY "country", "city"
ORDER BY COUNT(*) DESC;
-- cities are not set or not available in demo dataset
-- cannot give any information about the countries

-- cross referencin with other session instance for more information on these rows
SELECT "fullVisitorId", "country" 
FROM all_sessions
WHERE "fullVisitorId" IN 	
						(SELECT "fullVisitorId" 
						FROM all_sessions
						WHERE country = '(not set)')
		AND country != '(not set)';
-- returned Null

-- Cross-checking against 'analytics' to see if there's any useful information here
SELECT * 
FROM analytics
WHERE "fullvisitorId"  IN 
	(SELECT "fullVisitorId" 
	FROM all_sessions
	WHERE "country" = '(not set)')
	ORDER BY "revenue" DESC;
-- This query returned "units_sold" and "revenue" as null.
-- Making decision to delete these rows

DELETE FROM all_sessions
WHERE "country" = '(not set)';
DELETE FROM all_sessions
WHERE "city" = '(not set)' OR "city" = 'not available in demo dataset';



SELECT  COUNT (DISTINCT ("fullvisitorId")) FROM analytics; --120 018
SELECT  COUNT (DISTINCT ("fullVisitorId")) FROM all_sessions; --6064

		
SELECT "fullVisitorId", COUNT(DISTINCT country), COUNT(DISTINCT city) FROM all_sessions
		GROUP BY "fullVisitorId" 
		
		HAVING COUNT(DISTINCT city)>1
		ORDER BY COUNT(DISTINCT city) desc;
-- returned 27 rows

SELECT DISTINCT("city") FROM all_sessions WHERE "fullVisitorId" = '7493352411612470985'
-- examining one of the rows

		
SELECT "fullVisitorId", "visitId", COUNT(DISTINCT country), COUNT(DISTINCT city) from all_sessions
		GROUP BY "fullVisitorId", "visitId"
		HAVING COUNT(DISTINCT city)>1
		ORDER BY COUNT(DISTINCT city) desc
-- returned 0 rows! 
-- meaning the 'fullvisitor' / 'visitId' can be a compound key
-- Taking this into the 'visitorKey_table'
-- Update foreign key from productinventory
ALTER TABLE all_sessions
ADD FOREIGN KEY ("productSKU") REFERENCES products("productSKU");
ALTER TABLE all_sessions
ADD FOREIGN KEY ("fullVisitorId", "visitId") REFERENCES visitorlog("fullVisitorId", "visitId");
SELECT * FROM all_sessions;
		
