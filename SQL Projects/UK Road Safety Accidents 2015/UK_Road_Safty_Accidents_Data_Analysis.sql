-- Create index on accident_index as it is using in both vehicles and accident tables and join clauses using indexes will perform faster
CREATE INDEX accident_index
on accident(accident_index);

CREATE INDEX accident_index
on vehicles(accident_index);


/* get Accident Severity and Total Accidents per Vehicle Type */
select vp.vehicle_type as 'Vehicle Type',accident_severity as 'Severity',count(vp.vehicle_type) as 'Number of Accidents'
from accident a join vehicles v 
on v.accident_index=a.accident_index 
join vehicle_types vp on vp.vehicle_code=v.vehicle_type
group by 1,2;


/* Average Severity by vehicle type */
select vp.vehicle_type as 'Vehicle Type',avg(accident_severity) AS 'Average Severity',count(vp.vehicle_type) as 'Number of Accidents'
from accident a join vehicles v
on v.accident_index=a.accident_index
join vehicle_types vp
on vp.vehicle_code=v.vehicle_type
group by 1;

/* Average Severity and Total Accidents by Motorcyle */
select vp.vehicle_type as 'Vehicle Type',count(vp.vehicle_type) as 'Number of Accidents'
from accident a join vehicles v
on v.accident_index=a.accident_index
join vehicle_types vp
on vp.vehicle_code=v.vehicle_type
where vp.vehicle_type like '%otorcycle%'
group by 1;


/* Top 3 vehicle Types with most Average Severity */
select vp.vehicle_type as 'Vehicle Type',avg(accident_severity) AS 'Average Severity',count(vp.vehicle_type) as 'Number of Accidents'
from accident a join vehicles v
on v.accident_index=a.accident_index
join vehicle_types vp
on vp.vehicle_code=v.vehicle_type
group by 1
order by 2 desc,3 desc
limit 3
;