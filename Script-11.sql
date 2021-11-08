-- Origin Destination Evaluation

-- Make Tabel for OD-Evaluation
create table od_matrix (
from_gs varchar,
to_gs varchar,
gps_ID text,
traveltime_min float8,
gps_points int,
veh_type text, 
bee_line_meter float8
)

-- Update SRID
update admarea_gemeinde set geom = st_setsrid(geom, 4326);
SELECT UpdateGeometrySRID('admarea_gemeinde','geom',4326);
select ST_SRID(geom), geom from admarea_gemeinde;

-- Fill OD-matrix from Track
INSERT INTO od_matrix (from_gs, to_gs, gps_id, traveltime_min, gps_points, veh_type, bee_line_meter) 
	select
		-- Origin
		(select sch from admarea_gemeinde where ST_intersects( (select geom from gps_asset_000002f6 order by timestamputc asc limit 1), geom)),
		-- Destination
		(select sch from admarea_gemeinde where ST_intersects( (select geom from gps_asset_000002f6 order by timestamputc desc limit 1), geom)),
		assetid, 
		-- Travel Time !!ATTENTION: day + hour + minute
		(DATE_PART('hour', (select timestamputc from gps_asset_000002f6 order by timestamputc desc limit 1)::time - (select timestamputc from gps_asset_000002f6 order by timestamputc asc limit 1)::time) *60 +
			DATE_PART('minute', (select timestamputc from gps_asset_000002f6 order by timestamputc desc limit 1)::time - (select timestamputc from gps_asset_000002f6 order by timestamputc asc limit 1)::time)), 
		(select count(*) from gps_asset_000002f6), 
		vehicletype, 
		(ST_Distance((select geom from gps_asset_000002f6 order by timestamputc asc limit 1)::geography, (select geom from gps_asset_000002f6 order by timestamputc desc limit 1)::geography))
	from gps_asset_000002f6 limit 1; --todo: where date = ...

-- Some Queries
SELECT assetid, count(*) FROM gps_adac_full GROUP BY assetid;
truncate od_dump;
drop table od_dump;
select count(*) from od_dump;
select count(*) from od_matrix;
select * from od_dump where gps_points > 15000;
select * into GPS_asset_212DCB06_maxP from gps_adac_full where assetid = '212DCB06';
select * into GPS_asset_212DCB06_track from gps_adac_full where assetid = 'D1890F08';
select * into GPS_asset_00BEF0BB_negativ from gps_adac_full where assetid = '00BEF0BB';

select * from GPS_asset_00BEF0BB_negativ;

select count(*) from GPS_asset_212DCB06_track;
select * from od_matrix_trips_2 where to_gs is null;--order by count desc;
select count(*) from od_matrix where from_gs = '09672134' and to_gs = '09679453';
select sum(count) from od_matrix_trips_2;
select * from od_matrix where from_gs is Null;

SELECT
   from_gs, to_gs,
	COUNT (*)
into
	od_matrix_trips_2
FROM
   od_matrix
GROUP BY
   from_gs, to_gs;
  
select sum(count) from od_matrix_trips;
select * from od_matrix_trips where from_gs != to_gs ORDER BY count desc limit 50;
select * from od_matrix_trips ORDER BY count desc limit 50;
select sum(count) from od_matrix_trips;


select * from od_matrix where from_gs != to_gs and gps_points < 500 order by gps_points desc;

-- todo: SUM not equal to distinct assetIDs
select count(*) from od_matrix where from_gs != to_gs;
select count(*) from od_matrix where from_gs = to_gs;

select count(*) from od_matrix_trips;


UPDATE od_matrix_trips_2
SET name_from = bez_gem
FROM
admarea_gemeinde
WHERE
od_matrix_trips_2.from_gs = admarea_gemeinde.sch;

select count(*) from od_matrix;
select count(*) from gps_adac_full;
select vehicletype from gps_asset_two;
select * into od_dump from od_matrix;
select * from od_dump where traveltime_min < 0;
select DATE_PART('minute', (select timestamputc from gps_asset_000002f6 order by timestamputc desc limit 1)) - DATE_PART('minute', (select timestamputc from gps_asset_000002f6 order by timestamputc asc limit 1));
drop table od_matrix_trips_2;

