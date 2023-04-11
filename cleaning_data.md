What issues will you address by cleaning the data?

Duplicated and inconsistent information. e.g. I created a new products table using the SKU as the primary key, and keeping on DESCription for the product Name


Queries:
Below, provide the SQL queries you used to clean your data.

--Analytics:
-- after reviewing with excel, removing columns that are empty or single-valued
ALTER TABLE analytics
DROP COLUMN "userid";
ALTER TABLE analytics
DROP COLUMN "socialEngagementType";
ALTER TABLE analytics
DROP COLUMN "bounces";

-- modify revenue and unitprice by 1,000,000
UPDATE analytics
SET unit_price = unit_price::float/1000000;
UPDATE analytics
SET revenue = revenue::float/1000000;
-- updating revenue column where null with unit_price * units_sold
-- also setting null values of revenue and units_sold to 0
ALTER TABLE analytics
ADD COLUMN UPDATEd_revenue float;
UPDATE analytics
SET UPDATE_revenue = 
    (CASE   WHEN revenue IS NOT null THEN revenue
            ELSE unit_price * units_sold
    END);
UPDATE analytics
SET revenue = 
    (CASE WHEN revenue IS null THEN 0
        ELSE UPDATEd_revenue
    END);
UPDATE analytics
SET units_sold = 
    (CASE WHEN units_sold IS null THEN 0
        EKSE units_sold
    END)

-- Cleaning all_sessions
-- after reviewing with excel, removing columns that are empty or single-valued, 
-- removing rows where "country" is not set
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
DELETE FROM all_sessions
WHERE "country" = '(not set)';

-- Cleaning and creating new Products table
-- Create a new product table with 2 columns:
-- productSKU and productName
-- get this data FROM the old_products table, sales_by_sku and all_sessions

CREATE TABLE products (
    "productSKU" varchar(40),
    "productName" varchar(100));
    
INSERT INTO products
    SELECT "SKU", "name"
    FROM old_products; -- 1092 rows
SELECT COUNT (DISTINCT "productSKU") FROM products;
    
INSERT INTO products 
    SELECT "productSKU", 'no_name_data_from_sales_by_sku'
    FROM sales_by_sku
    WHERE "productSKU" not in 
                    (SELECT "productSKU"
                    FROM products); --1100 rows
                    
SELECT * FROM products; -- confirming the number 
SELECT COUNT (DISTINCT "productSKU") FROM products;

-- before I insert the names into the products table from all_sessions
-- I need to clean up the all_sessions names
-- first extract and group the names 
-- clean up duplicate names

-- method: Create a temp table SKU_names_from_all_session
    
CREATE TABLE temp_SKU_names_from_all_sessions (
    "productSKU" varchar(40),
    "productName" varchar(100));

SELECT COUNT (DISTINCT "productSKU") FROM all_sessions; --536 / used to check later
SELECT COUNT (DISTINCT "productSKU") 
FROM all_sessions
WHERE "productSKU" NOT IN (SELECT "productSKU" FROM products); -- 146

ALTER TABLE temp_SKU_names_from_all_sessions
ADD COLUMN "longestName" integer;

-- extract the SKU and names, use windows to count/identify duplicated names
-- sorting the names by length with the assumption that the longest names give the most details
-- adding all this data to the temp table
INSERT INTO temp_SKU_names_from_all_sessions
    SELECT "productSKU", "v2ProductName"
                    , row_number() over(
                        PARTITION BY "productSKU"
                        ORDER BY "productSKU", length("v2ProductName") DESC) 
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

-- Now I want to update the products name with the longer names in the 'analysis table'
                                    
SELECT temp_SKU_names_from_all_sessions."productSKU"
    , temp_SKU_names_from_all_sessions."productName" 
FROM products
RIGHT JOIN temp_SKU_names_from_all_sessions
ON products."productSKU" = products."productName"

WHERE LENGTH(temp_SKU_names_from_all_sessions."productName") > LENGTH(products."productName");

--This result is empty. Meaning i don't need to UPDATE the Names
SELECT * FROM products
ORDER BY "productName";

ALTER TABLE old_products
RENAME TO products_inventory;
ALTER TABLE products_inventory
DROP COLUMN "name";
ALTER TABLE products_inventory
RENAME COLUMN "SKU" TO "productSKU";
-- set the foreign key in products_inventory and sales_by_sku
ALTER TABLE products_inventory
ADD FOREIGN KEY ("productSKU") REFERENCES products("productSKU")

-- remove temp tables
DROP TABLE temp_SKU_names_from_all_sessions