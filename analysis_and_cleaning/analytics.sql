select * from analytics
select count(*) from analytics -- 4301122
select distinct "userid" from analytics -- 0

select count(*) from analytics 
	where "visitId" is not null -- 4301122
select count(distinct "visitId") from analytics-- 148642

select count(distinct "fullvisitorId") from analytics-- 120018
select count(*) from analytics 
	where "fullvisitorId" is not null -- 4301122
	
select count(distinct "bounces") from analytics -- 1
select distinct("socialEngagementType") from analytics -- 1
select distinct("channelGrouping") from analytics --8 channel groups