--- Clearning sales_report
--- Drop 'ratio'
alter table sales_report
	drop column ratio;
alter table sales_report
	add primary key ("productSKU");
	
select * from sales_report;


create table original_products as table products;

create table original_all_sessions as table all_sessions;
create table original_analytics as table analytics;

alter table products
	rename column "SKU" to "productSKU";
alter table products
	add primary key ("productSKU")

---------

create table original_sales_by_sku as table sales_by_sku
alter table sales_by_sku
	add primary key ("productSKU")
	
----

select * from sales_report
where "sentimentScore" is null
order by total_ordered DESC


select count(distinct "productSKU") from all_sessions -- 536
select count (*) from products
select count (distinct "productSKU") from products -- 1092
select count (distinct "productSKU") from sales_by_sku -- 462


-----
-- Create a table with just the product SKU and name
with products_inventory as (select 
	"productSKU" as product_sku
	, name as product_name
	from products
	order by product_name)
-- select * from products_inventory


select count (distinct "productSKU") from all_sessions
	where "productSKU"  not in (
								select product_sku from products_inventory);

--- 147 productsSKU in all_sessions that are not in products



with products_inventory as (select 
	"productSKU" as product_sku
	, name as product_name
	from products
	order by product_name)
-- select * from products_inventory

select count (distinct "productSKU") from sales_by_sku
	where ("productSKU") not in (
								select product_sku from products_inventory);
								
--- 8 productsSKU not in sales_by_sku

create table 

