select "v2ProductName"
	-- column to store the extracted search engine   as searchEngine
	, 	case 	when lower("v2ProductName") like '%youtube%' then 'Youtube'
		 		when lower("v2ProductName") like '%google%' then 'Google'
				when lower("v2ProductName") like '%android%' then 'Android'
				else "v2ProductName"
	  	end as "searchEngine"
	-- code to remove youtube and Google as productName	
	, 	case 	when lower("v2ProductName") like '%youtube%' 
				then initcap(trim(replace(lower("v2ProductName"), 'youtube','')))
				when lower("v2ProductName") like '%google%' 
				then initcap(trim(replace(lower("v2ProductName"), 'google','')))
				when lower("v2ProductName") like '%android%' 
				then initcap(trim(replace(lower("v2ProductName"), 'android','')))
				else 'No Data'
		end as "productName"
from all_sessions