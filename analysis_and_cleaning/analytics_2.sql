with analytics_columns as 
	(SELECT column_name
	  FROM information_schema.columns
	 WHERE table_schema = 'public'
	   AND table_name   = 'analytics')
	   
select count(*)
from analytics
where "revenue" is null;
	   
select count(*)
from analytics
where "unit_price" is null;

select * from analytics
order by "unit_price";

select * from analytics
where "timeonsite" is null --477465
	and "revenue" is not null
	
select count(length("fullvisitorId"))
from analytics
group by length("fullvisitorId")
     