
-- Question 1. 
--Question 1: Which cities and countries have 
-- the highest level of transaction revenues on the site?
-- Solution: Join visitorLocation with analytics to calculate revenue


select country, city, sum(revenue)
from analytics
	inner join visitorLocation
	on analytics."visitId" = visitorLocation."visitId"

group by country, city
order by sum(revenue) desc

-- The country is USA
-- The city is Sunnyvale, USA.

-- Question 2: What is the average number of products 
-- ordered from visitors in each city and country?
select country, city, avg(units_sold)::float
from analytics
	inner join visitorLocation
	on analytics."visitId" = visitorLocation."visitId"
where units_sold !=0
group by country, city
order by avg(units_sold) desc

--Question 3: Is there any pattern in the types (product categories) of 
--products ordered from visitors in each city and country?
select country, city, max(products.category)
from all_sessions
	inner join products
	on all_sessions."productSKU" = products."productSKU"
where products.category !='unset'
group by country, city
order by country, city;

---Question 4: What is the top-selling product from each city/country? 
--Can we find any pattern worthy of noting in the products sold?
with max_selling_products_by_country as
	(select country, city, max("productSKU") 
	from all_sessions
	group by country, city)
-- joining with modified products table to get the productName
select * 
from max_selling_products_by_country
	inner join products
	on max_selling_products_by_country.max = products."productSKU"
order by country, city;




--Question 5: Can we summarize the impact 
--of revenue generated from each city/country?

select sum(revenue)
from analytics
	inner join visitorLocation
	on analytics."visitId" = visitorLocation."visitId";
-- Query for Total sum

select country, city, (sum(revenue)*100 / 
					   	(select sum(revenue)
						from analytics
							inner join visitorLocation
							on analytics."visitId" = visitorLocation."visitId"))::numeric(100,2) as percent_of_revenue
from analytics
	inner join visitorLocation
	on analytics."visitId" = visitorLocation."visitId"

group by country, city
order by sum(revenue) desc


