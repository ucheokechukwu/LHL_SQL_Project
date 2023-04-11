--DROP table visitorLog CASCADE
--creating visitor_Key_Index
SELECT DISTINCT "fullvisitorId", "visitId" FROM analytics; -- 20K
SELECT DISTINCT "fullVisitorId", "visitId" FROM all_sessions; -- 6K


CREATE TABLE visitorlog (
	"fullVisitorId" varchar(40),
	"visitId" integer);

WITH temp_table_of_IDs as 
(SELECT DISTINCT "fullvisitorId", "visitId" FROM analytics
UNION
SELECT DISTINCT "fullVisitorId", "visitId" FROM all_sessions)


INSERT INTO visitorlog
SELECT DISTINCT "fullvisitorId", "visitId" FROM temp_table_of_IDs; --26K results returned

SELECT * FROM visitorlog
ALTER TABLE visitorlog
ADD PRIMARY KEY ("fullVisitorId", "visitId");

-- Creating a table that indexes all the countries and cities
CREATE TABLE visitorlocation (LIKE visitorlog);
ALTER TABLE visitorlocation
ADD COLUMN "country" varchar (40);
ALTER TABLE visitorlocation
ADD COLUMN "city" varchar (40);


INSERT INTO visitorLocation
SELECT visitorlog."fullVisitorId", 
	visitorlog."visitId", 
	all_sessions.country,
	all_sessions.city
FROM visitorlog
	RIGHT JOIN all_sessions
	ON visitorlog."fullVisitorId" = all_sessions."fullVisitorId"
	AND visitorlog."visitId" = all_sessions."visitId";
	
SELECT * FROM visitorLocation;

ALTER TABLE visitorLocation
ADD FOREIGN KEY ("fullVisitorId", "visitId") REFERENCES visitorlog("fullVisitorId", "visitId");
