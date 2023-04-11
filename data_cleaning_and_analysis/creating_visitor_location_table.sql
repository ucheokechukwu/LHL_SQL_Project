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
		
-- set Primary Key
alter table visitorLocation
add primary key ("fullVisitorId", "visitId")

		
		
with pair as 
		(select distinct "fullVisitorId", "visitId" from visitorLocation)
		
select "fullVisitorId", "visitId", "country", "city", row_number()
		over(partition by "fullVisitorId", "visitId"
			order by "country", "city")
from visitorLocation
where "fullVisitorId" in (select "fullVisitorId" from pair)
		and "visitId" in (select "visitId" from pair)


		

		
-- Trying to get city information
with unknown_city as 		
(select "fullVisitorId", "visitId", "country", "city" from visitorLocation
		where "city" = '(not set)')
		
select * from visitorLocation
		where "fullVisitorId" in (select "fullVisitorId" from unknown_city)
		and city != '(not set)'; -- returned 2 rows
--Returned "not available in demo datset"/
--Will revisit this data to see if it's worth keeping in any table
		
		select * from analytics where "fullvisitorId" = '6758601615954415907'
		and "visitId" = 1487359402
-- returned 0 values for both queries. Will remove these rows
-- deleting the 2 rows of city = '(not set)' as part of cleaning
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
		
		