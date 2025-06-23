create database UK_road_safety_accidents;

use UK_road_safety_accidents;

create table vehicles(
accident_index varchar(13),
vehicle_type varchar(50)
);
SET GLOBAL local_infile=ON;


create table vehicle_types(
vehicle_code int,
vehicle_type varchar(30)
);




CREATE TABLE accident(
	accident_index VARCHAR(13),
    accident_severity INT
);

-- Load DATA

Load Data local infile 'C:\\Users\\itssa\\Downloads\\vehicles_2015.csv'
into table vehicles
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(@col1, @dummy, @col2, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET accident_index=@col1,vehicle_type=@col2;


Load Data local infile 'C:\\Users\\itssa\\Downloads\\vehicle_type.csv'
into table vehicles
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(@col1, @dummy, @col2, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET accident_index=@col1,vehicle_type=@col2;


LOAD DATA LOCAL INFILE 'C:\\Users\\itssa\\Downloads\\accidents_2015.csv'
INTO TABLE accident
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @dummy, @dummy, @dummy, @dummy, @dummy, @col2, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET accident_index=@col1, accident_severity=@col2;

select * from vehicle_types;
select count(*) from accident;
select count(*) from vehicles;