-- Going from sales_by_sku to products
select * from products;
select count(*) from products;
--1092 rows
select count(distinct "SKU") from products
--1092
--good candidate for primary key
--so maybe this should be 1 table, not 2?
select length("SKU"), count(*) from products
group by length("SKU")
order by length("SKU");
-- 7-long are 170
-- 12-long are 169
-- 14-long are 751
-- 15-long are 1
-- 16-long are 1

select * from products
where length("SKU") in (15,16);
-- PC gaming speakers (15) & USB wired soundbar (16)

(select * from products
where length("SKU") = 12
limit 5)
union
(select * from products
where length("SKU") = 14
limit 5)
order by "SKU"
-- nothing seems unique about the SKUs




