--going to try merging sales_by_SKU and products
select * 
from products
	full outer join sales_by_sku
	on products."SKU" = sales_by_sku."productSKU"

--454 on inner join
--1100 on full outer join
-- note that products were 1092
-- let's check what sold items were not in the products list

select * 
from products
	right join sales_by_sku
	on products."SKU" = sales_by_sku."productSKU"
	where products."SKU" is null
	
-- no discernable pattern, some where 7-long and 2 were longer