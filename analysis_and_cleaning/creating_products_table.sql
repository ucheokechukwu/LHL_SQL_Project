create table old_products as table original_products;
create table products (
	"productSKU" varchar(40),
	"productName" varchar(100)
);

insert into products
	select "SKU", "name"
	from old_products;
	
insert into products ("productSKU")
	select "productSKU"
	from sales_by_sku
	where "productSKU" not in (select "productSKU" from products);
	
alter table products
add primary key ("productSKU");

select * from products;

-- all_sessions

alter table all_sessions
drop column "itemRevenue";
alter table all_sessions
drop column "itemQuantity";

--analytics

alter table analytics
drop column "bounces"
alter table analytics
drop column "userid";

select * from analytics
where units_sold is not null and units_sold != 0
