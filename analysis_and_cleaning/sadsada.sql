
-- Question 1. 
--Which cities have the highest level of transaction revenues on the site
-- Solution: Join visitorLocation with analytics to calculate revenue


select country, city, sum(revenue) 
from analytics
	left join visitorLocation
	on visitorLocation."fullVisitorId" = analytics."fullvisitorId"
		and visitorLocation."visitId" = analytics."visitId"
where revenue is not null
group by country, city
order by sum(revenue)


