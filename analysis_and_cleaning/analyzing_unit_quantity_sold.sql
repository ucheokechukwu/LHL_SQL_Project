select count ("units_sold") from analytics --95147
where "units_sold" is not null and "units_sold" !=0;

select count ("units_sold") from analytics 
where "units_sold" is not null and "units_sold" !=0;
-- still 95147

--examining the trend of information

select "units_sold", count ("units_sold") from analytics
group by "units_sold"
order by "units_sold" desc;
-- found one -89 that was probably 89? will compare to all_sessions to find out if this data is incorrect.
-- found 70497 of 1 unit_sold which is not impossible but still need to verify

select * from analytics
where "units_sold" = -89;

-- "fullvisitorId" is '1685328079244104306'
-- "visitId" is '1498835506'
-- "visitStartTime" is '1498835506'

-- oh look at that.. is it visitId and visitStartTime... identical???

select "visitId", "visitStartTime",
	"visitId" = "visitStartTime"
from analytics
where "visitId" != "visitStartTime";
-- returned 38610

-- testing one result

select * from analytics where "visitId" = 1499529983
order by "visitStartTime";

select count (distinct "visitStartTime") from analytics ;
select count(*) from analytics;

select "fullvisitorId", "visitId", rank() over(
	partition by "fullvisitorId"
	order by "visitId")
from analytics
order by "fullvisitorId"
limit 1000







