select "SKU", "name" from products

select "productSKU", "name" from sales_report


select count(*) from sales_report

select * from sales_report
where "total_ordered" = 0
and not (ratio = 0 or ratio is null)

-- Ratio is 0 or null when total_ordered is 0. 

with non_zero_ratio as
 	(select * from sales_report
 	where "total_ordered" !=0)
-- select * from non_zero_ratio
select "total_ordered"::decimal/"stockLevel"::decimal, "ratio" from non_zero_ratio

-- So ratio is total_ordered / stockLevel! Yay!


