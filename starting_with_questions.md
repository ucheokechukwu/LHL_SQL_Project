Answer the following questions and provide the SQL queries used to find the answer.

    
**Question 1: Which cities and countries have the highest level of transaction revenues on the site?**


SQL Queries:

select country, city, sum(revenue)
from analytics
	inner join visitorLocation
	on analytics."visitId" = visitorLocation."visitId"

group by country, city
order by sum(revenue) desc



Answer:
-- The country is USA
-- The city is Sunnyvale, USA.



**Question 2: What is the average number of products ordered from visitors in each city and country?**


SQL Queries:

select country, city, avg(units_sold)::float
from analytics
	inner join visitorLocation
	on analytics."visitId" = visitorLocation."visitId"
where units_sold !=0
group by country, city
order by avg(units_sold) desc

Answer:
United States/Chicago - 5 and United States/Pittburg - 4




**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**


SQL Queries:
select country, city, max(products.category)
from all_sessions
	inner join products
	on all_sessions."productSKU" = products."productSKU"
where products.category !='unset'
group by country, city
order by country, city


Answer:





**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**


SQL Queries:

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


Answer:





**Question 5: Can we summarize the impact of revenue generated from each city/country?**

SQL Queries:

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


Answer:

United States/ unknown city at 24.75% and United States/New York at 23.5%





