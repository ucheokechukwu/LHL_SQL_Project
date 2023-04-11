--Analyzing and Cleaning sales_report
CREATE TABLE sales_report AS TABLE original_sales_report
SELECT * FROM sales_report;
-- 454 rows which is the same as this query result:
SELECT * 
FROM original_products
	INNER JOIN original_sales_by_sku
	ON original_products."SKU" = original_sales_by_sku."productSKU";
-- this is also 454

WITH sales_report_join AS
	(SELECT * 
	FROM original_products
		INNER JOIN original_sales_by_sku
		ON original_products."SKU" = original_sales_by_sku."productSKU")
SELECT *
FROM sales_report
INNER JOIN sales_report_join
ON sales_report."productSKU"  = sales_report_join."productSKU"

-- inner join produced 454 rows. 
-- sales_report appears to be a join from 2 existing tables
-- investigating the ratio column
SELECT total_ordered::float/"stockLevel"::float, ratio 
	, total_ordered::float/"stockLevel"::float - ratio 
FROM sales_report
WHERE "stockLevel" IS NOT null AND "stockLevel" != 0;

-- add foreign key from products table
ALTER TABLE sales_report
ADD FOREIGN KEY ("productSKU") REFERENCES products("productSKU");