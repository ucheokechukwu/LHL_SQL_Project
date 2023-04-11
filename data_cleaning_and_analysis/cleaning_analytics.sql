--Cleaning analytics
DROP TABLE analytics; -- Checkpoint
CREATE TABLE analytics AS TABLE original_analytics;

--reviewing with excel, removing the following:
-- transactions - only 1 row has any data.
-- socialEngagementtype (same value across rows)
-- userID is empty
-- bounces only 1 row has any data


ALTER TABLE analytics
DROP COLUMN "userid";
ALTER TABLE analytics
DROP COLUMN "socialEngagementType";
ALTER TABLE analytics
DROP COLUMN "bounces";
-- modify revenue and unitprice by 1,000,000
-- replace Null revenue with 0
UPDATE analytics
SET unit_price = unit_price::float/1000000;
UPDATE analytics
SET revenue = revenue::float/1000000;

SELECT * FROM analytics WHERE revenue IS null;
--returned 4K results

DELETE FROM analytics
WHERE "units_sold" is Null and revenue is Null;

-- ALTER TABLE analytics
-- ADD COLUMN temp_revenue float;
UPDATE analytics
SET revenue = 
    (CASE   WHEN revenue IS NOT null THEN revenue
            ELSE unit_price * units_sold
    END);
SELECT * FROM analytics WHERE revenue IS null; -- 0
SELECT * FROM analytics WHERE units_sold IS null; -- 0
SELECT * FROM analytics; --95K rows now
-- revenue is Null when units_sold is null. 


-- Further analysis...
SELECT "units_sold", COUNT ("units_sold") FROM analytics
GROUP BY "units_sold"
ORDER BY "units_sold"; 
-- one value of -89??? impossible. checking against all_sessions
SELECT * from ANALYTICS
WHERE "units_sold" = -89;

-- "fullvisitorId" is '1685328079244104306'
-- "visitId" is '1498835506'
-- "visitStartTime" is '1498835506'
SELECT * from all_sessions where "fullVisitorId" = '1685328079244104306';
-- no result
DELETE FROM analytics
WHERE "units_sold" = -89;
--Examining these 2 columns...
SELECT "visitId", "visitStartTime",
	"visitId" = "visitStartTime"
FROM analytics
WHERE "visitId" = "visitStartTime"; -- 93K out of 95K  

ALTER TABLE analytics
ADD FOREIGN KEY ("fullvisitorId", "visitId") REFERENCES visitorlog("fullVisitorId", "visitId")

