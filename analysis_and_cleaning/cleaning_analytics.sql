--Cleaning analytics
drop table analytics;
create table analytics as table original_analytics;

--reviewing with excel, removing the following:


-- transactions - only 1 row has any data.
-- socialEngagementtype (same value across rows)
-- userID is empty
-- bounces only 1 row has any data

alter table analytics
drop column "userid";
alter table analytics
drop column "socialEngagementType";
alter table analytics
drop column "bounces";

-- modify revenue and unitprice by 1,000,000

update analytics
set unit_price = unit_price::float/1000000;
update analytics
set revenue = revenue::float/1000000;

select * from analytics
limit 20;

alter table analytics
add column updated_revenue float;

update analytics
set updated_revenue = 
	(case 	when revenue is not null then revenue
			else unit_price * units_sold
	end);
	
-- Quality control
select * from analytics where revenue is not null and units_sold is null;
-- returns 0 rows
select count(*) from analytics where units_sold is null and revenue is null
select count (*) from analytics where updated_revenue is not null

update analytics
set revenue = 
	(case when revenue is null then 0
		else updated_revenue
	end);

update analytics
set units_sold = 
	(case when units_sold is null then 0
		else units_sold
	end)

