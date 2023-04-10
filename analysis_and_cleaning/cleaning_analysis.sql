select count ("productQuantity") from all_sessions

select count ("units_sold") from analytics --95147
where "units_sold" is not null and "units_sold" !=0

select "units_sold", count ("units_sold") from analytics
group by "units_sold"
order by "units_sold"

select 
