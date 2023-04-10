create table new_products
(	
	"productSKU" varchar(40),
	"name" varchar(100),
	"orderedQuantity" integer,
	"stockLevel" integer,
    "restockingLeadTime" integer,
	"sentimentScore" numeric(2,1),
	"sentimentMagnitude" numeric (3,1)
);




insert into new_products
	select 	*
	from products
	
insert into new_products ("productSKU")
	select "productSKU"
	from sales_by_sku
	
insert into new_products ("productSKU")


select * from new_products

select new_products."productSKU",
		sales_by_sku."productSKU",
		"orderedQuantity",
		"total_ordered"
		
from new_products
full outer join sales_by_sku
on new_products."productSKU" = sales_by_sku."productSKU"
where new_products."productSKU" is null


--- Comparing table with all_sessions
--- Discovered there are products in all_sessions not in the full products list

select new_products."productSKU", "name",
	all_sessions."productSKU", "v2ProductName"
	from new_products
	full outer join all_sessions
	on new_products."productSKU"  = all_sessions."productSKU"
	where new_products."productSKU" is not null
	
	
select new_products."productSKU", "name", "orderedQuantity", 
	all_sessions."productSKU", "v2ProductName", "productQuantity"
	from new_products
	full outer join all_sessions
	on new_products."productSKU"  = all_sessions."productSKU"
	where new_products."productSKU" is not null
	order by "productQuantity" desc

	