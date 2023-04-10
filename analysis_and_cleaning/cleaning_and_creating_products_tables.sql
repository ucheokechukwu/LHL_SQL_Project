drop table products;
-- Create a new product table with 2 columns:
-- productSKU and productName

-- get this data from the old_products table, sales_by_sku and all_sessions

create table products (
	"productSKU" varchar(40),
	"productName" varchar(100));
	
insert into products
	select "SKU", "name"
	from old_products; -- 1092 rows
select count (distinct "productSKU") from products;
	
insert into products 
	select "productSKU", 'no_name_data_from_sales_by_sku'
	from sales_by_sku
	where "productSKU" not in 
					(select "productSKU"
					from products); --1100 rows
					
select * from products; -- confirming the number 
select count (distinct "productSKU") from products;

-- before I insert the names into the products table from all_sessions
-- I need to clean up the all_sessions names

-- first extract and group the names 
-- clean up duplicate names

-- method: Create a temp table SKU_names_from_all_session
 
	
create table temp_SKU_names_from_all_sessions (
	"productSKU" varchar(40),
	"productName" varchar(100));

select count (distinct "productSKU") from all_sessions; --536 / used to check later
select count (distinct "productSKU") 
from all_sessions
where "productSKU" not in (select "productSKU" from products); -- 146

alter table temp_SKU_names_from_all_sessions
add column "longestName" integer;

-- extract the SKU and names, use windows to count/identify duplicated names
-- sorting the names by length with the assumption that the longest names give the most details
-- adding all this data to the temp table
insert into temp_SKU_names_from_all_sessions
	select "productSKU", "v2ProductName"
					, row_number() over(
						partition by "productSKU"
						order by "productSKU", length("v2ProductName") desc) 
						as "longestName"
	from all_sessions;

-- removing all the duplicate names
delete from temp_SKU_names_from_all_sessions
where "longestName" > 1;
-- Quality check
select count(*) from temp_SKU_names_from_all_sessions; -- 536, 
-- 536 is the same as unique SKUs from original analysis table


-- now insert this table into the products table

insert into products
	select "productSKU", "productName" 
	from temp_SKU_names_from_all_sessions
	where "productSKU" not in (select "productSKU" 
							   from products); 
-- inserted 146 new rows, confirming the original value

-- Now I want to update the products name with the longer names in the 'analysis table'
									
select temp_SKU_names_from_all_sessions."productSKU"
	, temp_SKU_names_from_all_sessions."productName" 
from products
right join temp_SKU_names_from_all_sessions
on products."productSKU" = products."productName"

where length(temp_SKU_names_from_all_sessions."productName") > length(products."productName");

--This result is empty. Meaning i don't need to update the Names
select * from products
order by "productName";

select * from products where "productName" = 'no_name_data_from_sales_by_sku';

-- Observation: A lot of "duplicated" 'productName's. Could this be duplicate data? 
-- Potentially. But coudl also be different size e.g. t-shirts sizes have different SKUs








	


	
	