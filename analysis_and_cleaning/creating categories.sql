-- Creating a new column for Product Category
-- Creating/ testing function
select "v2ProductCategory",
case
	when lower("v2ProductCategory") like '%apparel/kid%' then 'Apparel - Kids'
	when lower("v2ProductCategory") like '%apparel/women%' then 'Apparel - Women'
	when lower("v2ProductCategory") like '%apparel/men%' then 'Apparel - Men'
	when lower("v2ProductCategory") like '%apparel%' then 'Apparel Misc'
	when lower("v2ProductCategory") like '%accessories%' then 'Accessories'
	when lower("v2ProductCategory") like '%drinkware%' then 'Drinkware'
	when lower("v2ProductCategory") like '%brands%' then 'Brands'
	when lower("v2ProductCategory") like '%kids%' then 'Kids'
	when lower("v2ProductCategory") like '%lifestyle%' then 'Lifestyle'
	when lower("v2ProductCategory") like '%office%' then 'Accesories'
	when lower("v2ProductCategory") like '%electronics%' then 'Electronics'
	when lower("v2ProductCategory") like '%pet%' then 'Pets'
	when lower("v2ProductCategory") like '%brand%' then 'Brand Misc'
	
	else 'unset'
	end
	
from all_sessions
where "v2ProductCategory" = '${escCatTitle}'
limit 50;
-- temporary table to store values
create table temp_product_sku_category (
	productsku varchar(40),
	v2productcategory varchar(100),
	productcategory varchar(100)
);

insert into temp_product_sku_category
select 	"productSKU", 
		"v2ProductCategory",
		case
	when lower("v2ProductCategory") like '%apparel/kid%' then 'Apparel - Kids'
	when lower("v2ProductCategory") like '%apparel/women%' then 'Apparel - Women'
	when lower("v2ProductCategory") like '%apparel/men%' then 'Apparel - Men'
	when lower("v2ProductCategory") like '%apparel%' then 'Apparel Misc'
	when lower("v2ProductCategory") like '%accessories%' then 'Accessories'
	when lower("v2ProductCategory") like '%drinkware%' then 'Drinkware'
	when lower("v2ProductCategory") like '%brands%' then 'Brands'
	when lower("v2ProductCategory") like '%kids%' then 'Kids'
	when lower("v2ProductCategory") like '%lifestyle%' then 'Lifestyle'
	when lower("v2ProductCategory") like '%office%' then 'Accesories'
	when lower("v2ProductCategory") like '%electronics%' then 'Electronics'
	when lower("v2ProductCategory") like '%pet%' then 'Pets'
	when lower("v2ProductCategory") like '%brand%' then 'Brand Misc'
	
	else 'unset'
	end as productcategory
	
from all_sessions;

--- back up table
create table products_v2 as table products;
alter table products_v2
add column cateogry varchar(100);

with category_sorting as 
	(select productsku, max(productcategory) as max 
	from temp_product_sku_category
	group by productsku)

select products."productSKU", products."productName", category_sorting.max
from products
inner join category_sorting
on products."productSKU" = category_sorting.productsku

truncate table products_v2;

with category_sorting as 
	(select productsku, max(productcategory) as max 
	from temp_product_sku_category
	group by productsku)
insert into products_v2

(select products."productSKU", products."productName", category_sorting.max
from products
inner join category_sorting
on products."productSKU" = category_sorting.productsku);

drop table temp_product_sku_category; -- deleting temporary tables
drop table products;
create table products as products_v2;
drop table products_v2;

select * from products





