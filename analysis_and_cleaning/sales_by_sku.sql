select * from sales_by_sku; --462 rows in this table
select count(*) from sales_by_sku; --confirming 462 rows
select count (distinct "productSKU") from sales_by_sku;
-- 462 distinct productSKU from sales_by_sku
-- good candidate for Primary Key
-- further check 
select * from sales_by_sku
order by "productSKU";
-- observed that the primary key has variable representation
select length("productSKU"), count(*) from sales_by_sku
group by length("productSKU");
-- to check the arrangment of productSKU formats
-- 12-long are 115;
-- 14-long are 269;
-- 7-long are 78;

-- will investigate other tables to see if this pattern
-- is related to time or product type

select * from sales_by_sku
order by length("productSKU");
-- no orders from 7-long products

select * from sales_by_sku
order by total_ordered desc;