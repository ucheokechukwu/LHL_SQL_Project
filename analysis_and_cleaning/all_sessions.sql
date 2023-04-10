select * from all_sessions
select distinct ("fullVisitorId") from all_sessions


select "fullVisitorId", count(*) from all_sessions
group by "fullVisitorId"
order by count(*) desc
-- repeated visits from fullVisitorID. 
-- unsuitable for Primary Key

-- Questions:
-- Possibly unnecessary columns:
-- Currency - only one value.
-- City - so many missing values
-- 

select distinct "productVariant" from all_sessions; -- 11
select * from all_sessions
where "productVariant" is not Null; -- 1000