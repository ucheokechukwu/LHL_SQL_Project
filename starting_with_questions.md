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





**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**


SQL Queries:



Answer:





**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**


SQL Queries:



Answer:





**Question 5: Can we summarize the impact of revenue generated from each city/country?**

SQL Queries:



Answer:







