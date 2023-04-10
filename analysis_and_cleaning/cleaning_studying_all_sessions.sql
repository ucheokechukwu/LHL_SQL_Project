drop table all_sessions;
create table all_sessions as table original_all_sessions;

--reviewing with excel, removing the following:
-- productrefundAmount - all blanks
-- pageTitle is redundant with an v2ProductName

-- transactions - only 1 row has any data.
-- itemQuantity (empty)
-- itemRevenue (empty)
-- searchKeyWord (empty)
-- product Variant (would be great for the products table)
-- currency code - delete it. they're all USD

-- put pagepathlevel, ecommerce_action, type, step in another table...

alter table all_sessions
drop column "productRefundAmount";
alter table all_sessions
drop column "pageTitle";
alter table all_sessions
drop column "transactions";
alter table all_sessions
drop column "itemQuantity";
alter table all_sessions
drop column "itemRevenue";
alter table all_sessions
drop column "searchKeyword";

-- select * from all_sessions
-- where "transactionRevenue" !=0;

select "fullVisitorId", count("fullVisitorId") from all_sessions
group by "fullVisitorId"
order by count ("fullVisitorId") desc;

select "country", count(*) from all_sessions
group by "country"
order by count(*) desc;
-- 24 rows have 'not set'
-- check the city
select "country", "city", count(*) from all_sessions
where "country" = '(not set)'
group by "country", "city"
order by count(*) desc;
-- cities are not set or not available in demo dataset
-- cannot give any information about the countries


select "fullVisitorId", "country" 
from all_sessions
where "fullVisitorId" in 	
							(select "fullVisitorId" 
							from all_sessions
							where country = '(not set)')
	 and country != '(not set)'

-- returned Null

select "fullVisitorId", "visitId" 
from all_sessions
where "country" = '(not set)'; 

-- Cross-checking against 'analytics' to see if there's any useful information here
select * 
from analytics
where "fullvisitorId"  in 
	(select "fullVisitorId" 
	from all_sessions
	where "country" = '(not set)')
	order by "revenue" desc;
	
-- This table returned "units_sold" and "revenue" as null.



-- Making decision to delete these rows

delete from all_sessions
where "country" = '(not set)';

-- Comparing revenues from all_sessions and analytics

select * from all_sessions
where "totalTransactionRevenue" is not null;

select * from analytics
where "fullvisitorId" in 
			(select "fullVisitorId" from all_sessions
			where "totalTransactionRevenue" is not null);
			
select analytics.revenue,
	all_sessions."totalTransactionRevenue"
from analytics
inner join all_sessions
	on analytics."fullvisitorId" = all_sessions."fullVisitorId"
	
where all_sessions."totalTransactionRevenue"  is not null
order by all_sessions."totalTransactionRevenue", analytics.revenue desc;

select revenue, unit_price * units_sold, (revenue::float*100 - unit_price * units_sold)/revenue::float as difference
from analytics
where revenue is not null
order by difference desc;

--Analyzing Revenue & Unit Price
--There is a connection between the 2 values
-- where revenue column exists, the product of unit price and sold is practically equivalent

select analytics.revenue,
	all_sessions."totalTransactionRevenue"
from analytics
inner join all_sessions
	on analytics."visitId" = all_sessions."visitId"
	
where all_sessions."totalTransactionRevenue"  is not null
and analytics.revenue is not null
order by all_sessions."totalTransactionRevenue", analytics.revenue desc;
--54 results


select analytics.revenue,
	all_sessions."totalTransactionRevenue"
from analytics
inner join all_sessions
	on analytics."fullvisitorId" = all_sessions."fullVisitorId"
	
where all_sessions."totalTransactionRevenue"  is not null
and analytics.revenue is not null
order by all_sessions."totalTransactionRevenue", analytics.revenue desc;

--66 results

select  count (distinct ("fullvisitorId")) from analytics; --120 018
select  count (distinct ("fullVisitorId")) from all_sessions; --14201

select length("fullvisitorId"), count (length("fullvisitorId")) from analytics
group by length("fullvisitorId");

select (distinct ("fullvisitorId") from analytics
		length("fullvisitorId") = 18;
		
-- Ok this is confusing!
-- Create a table of VisitorId by country and city
		
select "fullVisitorId", count(distinct country), count(distinct city) from all_sessions
		group by "fullVisitorId" 
		
		having count(distinct city)>1
		order by count(distinct city) desc;
-- returned 27 rows

select distinct("city") from all_sessions where "fullVisitorId" = '7493352411612470985'
-- most of this values are empty
		
select "fullVisitorId", "visitId", count(distinct country), count(distinct city) from all_sessions
		group by "fullVisitorId", "visitId"
		-- 14201 but adding a filter to be sure...
		having count(distinct city)>1
		order by count(distinct city) desc
-- returned 0 rows! Hurray! 
-- without the filter 14538 rows
		
drop table visitorLocation;		
create table visitorLocation (
	"fullVisitorId" varchar (40),
	"visitId" integer,
	"country" varchar(40),
	"city" varchar(40));
		
-- insert into visitorLocation
-- create a temp table of visitorId and visitId. will refer to it often
drop table temp_visitorLocation;	
create table temp_visitorLocation (
	"fullVisitorId" varchar (40),
	"visitId" integer);

insert into temp_visitorLocation
	select "fullVisitorId", "visitId" from all_sessions
			group by "fullVisitorId", "visitId"
			-- 14561 but adding a filter to be sure...
			order by "fullVisitorId", "visitId";
		

		
		
		
		
		
		
		


insert into visitorLocation
		
	select 		temp_visitorLocation."fullVisitorId"
				, temp_visitorLocation."visitId"
				, "country"
				, "city" 
	from 	all_sessions
			right join temp_visitorLocation
			on all_sessions."fullVisitorId" = temp_visitorLocation."fullVisitorId"
			and all_sessions."visitId" = temp_visitorLocation."visitId"
-- 	where "city" != 'not available in demo datset'
	order by temp_visitorLocation."fullVisitorId";
		
-- Trying to get city information
with unknown_city as 		
(select "fullVisitorId", "visitId", "country", "city" from visitorLocation
		where "city" = '(not set)')
		
select * from visitorLocation
		where "fullVisitorId" in (select "fullVisitorId" from unknown_city)
		and city != '(not set)';
--Returned "not available in demo datset"/
--Will revisit this data to see if it's worth keeping in any table
		
		select * from analytics where "fullvisitorId" = '6758601615954415907'
		and "visitId" = 1487359402
-- returned 0 values for both queries. Will remove these rows

delete from all_sessions
where "fullVisitorId" = '6758601615954415907'
	and "visitId" = 1487359402;
delete from all_sessions
where "fullVisitorId" = '6080401888984107817'
	and "visitId" = 1487230580;
		

delete from visitorLocation
where "fullVisitorId" = '6758601615954415907'
	and "visitId" = 1487359402;
delete from visitorLocation
where "fullVisitorId" = '6080401888984107817'
	and "visitId" = 1487230580;

		
with unknown_city as 		
(select "fullVisitorId", "visitId", "country", "city" from visitorLocation
		where "city" = 'not available in demo dataset')
		
select * from visitorLocation
		where "fullVisitorId" in (select "fullVisitorId" from unknown_city)
		and city != 'not available in demo dataset'
		order by "fullVisitorId"

-- returned 34 values

-- how to extract what is relevant...

create table temp_visitor_location_missing_city (
	"fullVisitorId" varchar (40),
	"visitId" integer);
		
create table temp_missing_city (like visitorLocation);
create table temp_city (like visitorLocation);
		
insert into temp_missing_city
select "fullVisitorId", "visitId", "country", "city" from visitorLocation
		where "city" = 'not available in demo dataset';

insert into temp_city
(with unknown_city as 		
(select "fullVisitorId", "visitId", "country", "city" from visitorLocation
		where "city" = 'not available in demo dataset')
		
select * from visitorLocation
		where "fullVisitorId" in (select "fullVisitorId" from unknown_city)
		and city != 'not available in demo dataset'
		order by "fullVisitorId");
		
		select * from temp_city

with combo_table as 
(select 	temp_missing_city."fullVisitorId"
 			, temp_missing_city."visitId"
 			, temp_missing_city."country"
 			, temp_city."city"
		
		from 
		temp_missing_city left join temp_city
		on temp_missing_city."fullVisitorId" = temp_city."fullVisitorId"
		and temp_missing_city."country" = temp_city."country"
		where temp_city."city" is not null)
select * from combo_table;

with combo_table as 
(select 	temp_missing_city."fullVisitorId"
 			, temp_missing_city."visitId"
 			, temp_missing_city."country"
 			, temp_city."city"
		
		from 
		temp_missing_city left join temp_city
		on temp_missing_city."fullVisitorId" = temp_city."fullVisitorId"
		and temp_missing_city."country" = temp_city."country"
		where temp_city."city" is not null)
select revenue from analytics where "fullvisitorId" in 
		(select 	"fullVisitorId" from combo_table)
		and revenue is not null
		
-- Returned 29 values.
		
select * from visitorLocation where "city" = 'not available in demo dataset'
		
with combo_table as 
(select 	temp_missing_city."fullVisitorId"
 			, temp_missing_city."visitId"
 			, temp_missing_city."country"
 			, temp_city."city"
		
		from 
		temp_missing_city left join temp_city
		on temp_missing_city."fullVisitorId" = temp_city."fullVisitorId"
		and temp_missing_city."country" = temp_city."country"
		where temp_city."city" is not null)
		
delete from visitorLocation
		where 
		("fullVisitorId", "visitId", "country") = 
		select ("fullVisitorId, "visitId", "country")
		from combo_table)
with combo_table as 
(select 	temp_missing_city."fullVisitorId"
 			, temp_missing_city."visitId"
 			, temp_missing_city."country"
 			, temp_city."city"
		
		from 
		temp_missing_city left join temp_city
		on temp_missing_city."fullVisitorId" = temp_city."fullVisitorId"
		and temp_missing_city."country" = temp_city."country"
		where temp_city."city" is not null)
		
select * from visitorLocation
where "fullVisitorId" in (select "fullVisitorId" from combo_table)
and "visitId" in (select "visitId" from combo_table)
		
		