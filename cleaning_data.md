What issues will you address by cleaning the data?

* Removing unnecesary columns with empty values or single-valued data.
* Removing instances without sufficient data.
* Restructuring the data to have identity keys 
- creating a products table with indexing, that links to the other tables.
- Creating a visitorlog table with compound indexing.



Queries:
Below, provide the SQL queries you used to clean your data.

--
-- Analyzing the Products table

CREATE TABLE products AS TABLE original_products
SELECT COUNT (*)
FROM products; --1092

SELECT COUNT (DISTINCT "SKU")
FROM products; --1092
-- confirming that the SKUs are unique identifiers, no duplicates

SELECT COUNT (DISTINCT "name")
FROM products; --313

SELECT NAME,
	COUNT(*)
FROM products
GROUP BY NAME -- analyzing the data most of the duplicate names are clothes which could be size differences
-- Analyzing the sales_by_sku table

SELECT *
FROM sales_by_sku; -- 462 rows

SELECT COUNT (*) - COUNT (DISTINCT "productSKU")
FROM sales_by_sku; --- 0



-- Cleaning - Create a single table productlist with productSKU, productName, productCategory
-- Renaming the existing table as product inventory
CREATE TABLE productinventory AS TABLE products;
SELECT * FROM productinventory; --returned 1092 quality check
ALTER TABLE productinventory
DROP COLUMN "name";
ALTER TABLE products
RENAME COLUMN "SKU" TO "productSKU";
ALTER TABLE products
RENAME COLUMN "name" TO "productName";
ALTER TABLE products
DROP COLUMN "orderedQuantity";
ALTER TABLE products
DROP COLUMN "stockLevel";
ALTER TABLE products
DROP COLUMN "restockingLeadTime";
ALTER TABLE products
DROP COLUMN "sentimentScore";
ALTER TABLE products
DROP COLUMN "sentimentMagnitude";
SELECT * FROM products; -- 1092 2 rows
-- importing rows from sales_by_sku
INSERT INTO products 
	SELECT "productSKU", 'no_name_data_from_sales_by_sku'
	FROM sales_by_sku
	WHERE "productSKU" NOT IN 
					(SELECT "productSKU"
					FROM products); --1100 rows
					
SELECT * FROM products; -- confirming the number 
SELECT COUNT (DISTINCT "productSKU") FROM products; --1100

-- Analyzing data in the all_sessions for productSKU and productName
-- first extract and group the names 
-- clean up duplicate names
-- method: Create a temp table SKU_names_from_all_session
 
	
CREATE TABLE temp_SKU_names_from_all_sessions (
	"productSKU" varchar(40),
	"productName" varchar(100));
SELECT COUNT (DISTINCT "productSKU") FROM all_sessions; --536 / used for QA check later
SELECT COUNT (DISTINCT "productSKU") 
FROM all_sessions
WHERE "productSKU" NOT IN 
	(SELECT "productSKU" FROM products); -- 146 new productSKUs 

ALTER TABLE temp_SKU_names_from_all_sessions
ADD COLUMN "longestName" integer;

-- extract the SKU and names, use window views to count/identify duplicated names
-- sorting the names by length with the assumption that the longest names give the most details
-- adding all this data to the temp table
INSERT INTO temp_SKU_names_from_all_sessions
	SELECT "productSKU", "v2ProductName"
					, ROW_NUMBER() OVER(
						PARTITION BY "productSKU"
						ORDER BY "productSKU", LENGTH("v2ProductName") DESC) 
						AS "longestName"
	FROM all_sessions;

-- removing all the duplicate names
DELETE FROM temp_SKU_names_from_all_sessions
WHERE "longestName" > 1;
-- Quality check
SELECT COUNT(*) FROM temp_SKU_names_from_all_sessions; -- 536, 
-- 536 is the same as unique SKUs from original analysis table

-- now insert this table into the products table
INSERT INTO products
	SELECT "productSKU", "productName" 
	FROM temp_SKU_names_from_all_sessions
	WHERE "productSKU" NOT IN (SELECT "productSKU" 
							   FROM products); 
-- inserted 146 new rows, confirming the original value

SELECT temp_SKU_names_from_all_sessions."productSKU"
	, temp_SKU_names_from_all_sessions."productName" 
FROM products
RIGHT JOIN temp_SKU_names_from_all_sessions
ON products."productSKU" = products."productName"

WHERE LENGTH(temp_SKU_names_from_all_sessions."productName") > LENGTH(products."productName");

--This result is empty. Meaning i don't need to update the Names
-- delete temporary table
DROP TABLE temp_SKU_names_from_all_sessions;

-- View in Excel shows that v2ProductCategory needs to be cleaned
-- Creating case/then to simplify the Categories
-- using a temporary table to store values
CREATE TABLE temp_product_sku_category (
	productsku varchar(40),
	v2productcategory varchar(100),
	productcategory varchar(100)
);
INSERT INTO temp_product_sku_category
SELECT 	"productSKU", 
		"v2ProductCategory",
		CASE
	when lower("v2ProductCategory") like '%apparel/kid%' then 'Apparel - Kids'
	when lower("v2ProductCategory") like '%apparel/women%' then 'Apparel - Women'
	when lower("v2ProductCategory") like '%apparel/men%' then 'Apparel - Men'
	when lower("v2ProductCategory") like '%apparel%' then 'Apparel Misc'
	when lower("v2ProductCategory") like '%accessories%' then 'Accessories'
	when lower("v2ProductCategory") like '%drinkware%' then 'Drinkware'
	when lower("v2ProductCategory") like '%kids%' then 'Kids'
	when lower("v2ProductCategory") like '%lifestyle%' then 'Lifestyle'
	when lower("v2ProductCategory") like '%office%' then 'Accesories'
	when lower("v2ProductCategory") like '%electronics%' then 'Electronics'
	when lower("v2ProductCategory") like '%pet%' then 'Pets'
	when lower("v2ProductName") like '%youtube%' then 'Youtube Brand Misc'	
	when lower("v2ProductName") like '%google%' then 'Google Brand Misc'
	when lower("v2ProductName") like '%android%' then 'Android Brand Misc'
	when lower("v2ProductCategory") like '%brand%' then 'Brand Misc'
	
	else 'Uncategorized'
	end
from all_sessions
select * from temp_product_sku_category;
-- create another temp_product table to store the new information
create table temp_products as table products;
alter table temp_products
add column category varchar(100);

-- some products might be grouped under different categories
-- using grouping to choose the max category value
with category_sorting as 
	(select productsku, max(productcategory) as max 
	from temp_product_sku_category
	group by productsku)
select products."productSKU", products."productName", category_sorting.max
from products
	inner join category_sorting
	on products."productSKU" = category_sorting.productsku;

truncate table temp_products; -- checkpoint for re-running code if errors
-- inserting the previous table into temp_products
with category_sorting as 
	(select productsku, max(productcategory) as max 
	from temp_product_sku_category
	group by productsku)
insert into temp_products
	(select products."productSKU", products."productName", category_sorting.max
	from products
		inner join category_sorting
		on products."productSKU" = category_sorting.productsku);
select * from products;

select * from temp_products;
insert into temp_products ("productSKU", "productName")
	select * from products
	where "productSKU" not in (select "productSKU" from temp_products);

select * from temp_products; -- 1246, same as the original products table
-- creating categories
select * from temp_products where "category" is null;

update temp_products
set category = 
	case 		
			WHEN LOWER("v2ProductCategory") LIKE '%apparel/kid%' THEN 'Apparel - Kids'
	WHEN LOWER("v2ProductCategory") LIKE '%apparel/women%' THEN 'Apparel - Women'
	WHEN LOWER("v2ProductCategory") LIKE '%apparel/men%' THEN 'Apparel - Men'
	WHEN LOWER("v2ProductCategory") LIKE '%apparel%' THEN 'Apparel Misc'
	WHEN LOWER("v2ProductCategory") LIKE '%accessories%' THEN 'Accessories'
	WHEN LOWER("v2ProductCategory") LIKE '%drinkware%' THEN 'Drinkware'
	WHEN LOWER("v2ProductCategory") LIKE '%kids%' THEN 'Kids'
	WHEN LOWER("v2ProductCategory") LIKE '%lifestyle%' THEN 'Lifestyle'
	WHEN LOWER("v2ProductCategory") LIKE '%office%' THEN 'Accesories'
	WHEN LOWER("v2ProductCategory") LIKE '%electronics%' THEN 'Electronics'
	WHEN LOWER("v2ProductCategory") LIKE '%pet%' THEN 'Pets'
	WHEN LOWER("v2ProductName") LIKE '%youtube%' THEN 'Youtube Brand Misc'	
	WHEN LOWER("v2ProductName") LIKE '%google%' THEN 'Google Brand Misc'
	WHEN LOWER("v2ProductName") LIKE '%android%' THEN 'Android Brand Misc'
	WHEN LOWER("v2ProductCategory") LIKE '%brand%' THEN 'Brand Misc'
	
	ELSE 'Uncategorized'
	END
FROM all_sessions
SELECT * FROM temp_product_sku_category;
-- create another temp_product table to store the new information
CREATE TABLE temp_products AS TABLE products;
ALTER TABLE temp_products
ADD COLUMN category varchar(100);

-- some products might be grouped under different categories
-- using grouping to choose the max category value
WITH category_sorting AS 
	(select productsku, max(productcategory) AS max 
	FROM temp_product_sku_category
	GROUP BY productsku)
SELECT products."productSKU", products."productName", category_sorting.max
FROM products
	INNER JOIN category_sorting
	ON products."productSKU" = category_sorting.productsku;

TRUNCATE TABLE temp_products; -- checkpoint for re-running code if errors
-- inserting the previous table into temp_products
WITH category_sorting AS 
	(SELECT productsku, max(productcategory) AS max 
	FROM temp_product_sku_category
	GROUP BY productsku)
INSERT INTO temp_products
	(select products."productSKU", products."productName", category_sorting.max
	FROM products
		INNER JOIN category_sorting
		ON products."productSKU" = category_sorting.productsku);
SELECT * FROM products;

SELECT * FROM temp_products;
INSERT INTO temp_products ("productSKU", "productName")
	SELECT * FROM products
	WHERE "productSKU" NOT IN (SELECT "productSKU" FROM temp_products);

SELECT * FROM temp_products; -- 1246, same as the original products table
-- creating categories
SELECT * FROM temp_products WHERE "category" is null;

UPDATE temp_products
SET category = 
	CASE 		
			WHEN LOWER("productName") LIKE '%kids%' THEN 'Kids'
			WHEN LOWER("productName") LIKE '%toddler%' THEN 'Kids'
			WHEN LOWER("productName") LIKE '%men%' THEN 'Apparel - Men'
			WHEN LOWER("productName") LIKE '%women%' THEN 'Apparel - Women'
			WHEN LOWER("productName") LIKE '%tee%' THEN 'Apparel Misc'	
			WHEN LOWER("productName") LIKE '%jacket%' THEN 'Apparel Misc'	
			WHEN LOWER("productName") LIKE '%shirt%' THEN 'Apparel Misc'	
			WHEN LOWER("productName") LIKE '%office%' THEN 'Office'	
			WHEN LOWER("productName") LIKE '%gift card%' THEN 'Gift Card'	
			WHEN LOWER("productName") LIKE '%phone%' THEN 'Electronics'
			WHEN LOWER("productName") LIKE '%pet%' THEN 'Pet'
			WHEN LOWER("productName") LIKE '%cat%' THEN 'Pet'	
			WHEN LOWER("productName") LIKE '%youtube%' THEN 'Youtube Brand Misc'	
			WHEN LOWER("productName") LIKE '%google%' THEN 'Google Brand Misc'
			WHEN LOWER("productName") LIKE '%android%' THEN 'Android Brand Misc'
			WHEN LOWER("productName") LIKE '%brand%' THEN 'Brand Misc'
			ELSE 'Miscalleanous'

	END
WHERE category IS null;

SELECT COUNT (DISTINCT "productSKU") FROM temp_products; -- 1246 QA check
TRUNCATE products;
ALTER TABLE products
ADD COLUMN "productCategory" varchar(100);
INSERT INTO products
SELECT * FROM temp_products;
SELECT COUNT (DISTINCT "productSKU") FROM products; -- 1246 QA check

-- delete temps
DROP TABLE temp_products;

-- Finally set productSKU as the primary key
ALTER TABLE products
ADD PRIMARY KEY ("productSKU");

-- set the foreign key in products_inventory and sales_by_sku
ALTER TABLE productinventory
ADD FOREIGN KEY ("SKU") REFERENCES products("productSKU");
ALTER TABLE sales_by_sku
ADD FOREIGN KEY ("productSKU") REFERENCES products("productSKU");



--Analytics:
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


