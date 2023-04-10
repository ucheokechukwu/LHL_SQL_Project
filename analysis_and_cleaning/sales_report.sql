select * from sales_report;
-- 454 rows which is the same as this query result:
select * 
from products
	inner join sales_by_sku
	on products."SKU" = sales_by_sku."productSKU";
-- let's see if they're identical

with sales_report_join as
	(select * 
	from products
		inner join sales_by_sku
		on products."SKU" = sales_by_sku."productSKU")


select *
from sales_report
inner join sales_report_join
on sales_report."productSKU"  = sales_report_join."productSKU"

-- inner join produced 454 rows. Now we're getting somewhere!
-- what is ratio???