What issues will you address by cleaning the data?

Duplicated and inconsistent information. e.g. I created a new products table using the SKU as the primary key, and keeping on description for the product Name



Queries:
Below, provide the SQL queries you used to clean your data.

--Analytics:
-- after reviewing with excel, removing columns that are empty or single-valued
alter table analytics
drop column "userid";
alter table analytics
drop column "socialEngagementType";
alter table analytics
drop column "bounces";

-- modify revenue and unitprice by 1,000,000
update analytics
set unit_price = unit_price::float/1000000;
update analytics
set revenue = revenue::float/1000000;
-- updating revenue column where null with unit_price * units_sold
-- also setting null values of revenue and units_sold to 0
alter table analytics
add column updated_revenue float;
update analytics
set updated_revenue = 
	(case 	when revenue is not null then revenue
			else unit_price * units_sold
	end);
update analytics
set revenue = 
	(case when revenue is null then 0
		else updated_revenue
	end);
update analytics
set units_sold = 
	(case when units_sold is null then 0
		else units_sold
	end)


-- Cleaning all_sessions
-- after reviewing with excel, removing columns that are empty or single-valued, 
-- removing rows where "country" is not set
alter table all_sessions
drop column "productRefundAmount";
alter table all_sessions
drop column "pageTitle";
alter table all_sessions
drop column "transactions";
alter table all_sessions
drop column "itemQuantity";
alter table all_sessions
drop column "itemRevenue";
alter table all_sessions
drop column "searchKeyword";
delete from all_sessions
where "country" = '(not set)';

-- Cleaning and creating new Products table
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
-- Final set productSKU as the primary key
alter table products
add primary key ("productSKU")

-- Observation: A lot of "duplicated" 'productName's. Could this be duplicate data? 
-- Potentially. But coudl also be different size e.g. t-shirts sizes have different SKUs