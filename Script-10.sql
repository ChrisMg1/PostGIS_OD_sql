-- drop table if exists dauz_tangent;
drop table if exists temp_dauz_start_point;
drop table if exists temp_dauz_polygon;

-- Chose DAUZ
@set dauz = 9552;

-- Make DAUZ to PostGIS object
select st_setsrid(ST_MakePoint(
		(select longitude from dauz where bast_id = :dauz),
		(select latitude  from dauz where bast_id = :dauz)), 4326)
		into temp_dauz_start_point;

-- get gid for dauz
-- update dauz set dauz_gid = select gid from strassen_polyline2 where strassenna = (select road from dauz where bast_id = 9552) and cast (a_nr as integer) = (select abschnitt from dauz where bast_id = 9552);
update dauz set dauz_gid = (select gid from strassen_polyline2 where strassenna = road and cast (a_nr as integer) = abschnitt);

-- manually assign gid to DAUZ @ missing values
update dauz set dauz_gid = 25737 where bast_id = 9861;

-- make polygon arount that gid
update dauz set geom_poly = st_envelope((select geom from strassen_polyline2 where gid = dauz_gid)::geometry);

-- create points at sections from polygom and a_nr
update dauz set geom_intersect = ST_Intersection((ST_ExteriorRing(geom_poly)), (select geom from strassen_polyline2 where gid = dauz_gid));



-- find a_nr with more than one DAUZ
SELECT dauz_gid, COUNT(*) FROM dauz GROUP BY dauz_gid HAVING COUNT(*) > 1;
select * from dauz where geom_tangent is not null;
select count(*) from dauz;-- where geom_poly is not null;


-- Create Tangents

update dauz set geom_tangent = 
ST_Union( 
ST_MakeLine(
	st_setsrid(ST_MakePoint(longitude, latitude), 4326)::geometry, 
	ST_Project(
		ST_MakePoint(longitude, latitude)::geography, 
		0.25 * ST_Distance(
			(select (ST_DumpPoints(geom_intersect)).geom order by geom desc limit 1)::geography,
			(select (ST_DumpPoints(geom_intersect)).geom order by geom asc  limit 1)::geography			
		),
		0 + ST_Azimuth(
			(select (ST_DumpPoints(geom_intersect)).geom order by geom desc limit 1)::geography,
			(select (ST_DumpPoints(geom_intersect)).geom order by geom asc  limit 1)::geography			
		)
	)::geometry
), 
ST_MakeLine(
	st_setsrid(ST_MakePoint(longitude, latitude), 4326)::geometry,
	ST_Project(
		ST_MakePoint(longitude, latitude), 
		0.25 * ST_Distance(
			(select (ST_DumpPoints(geom_intersect)).geom order by geom desc limit 1)::geography,
			(select (ST_DumpPoints(geom_intersect)).geom order by geom asc  limit 1)::geography			
		), 		
		pi() + ST_Azimuth(
			(select (ST_DumpPoints(geom_intersect)).geom order by geom desc limit 1)::geography,
			(select (ST_DumpPoints(geom_intersect)).geom order by geom asc  limit 1)::geography			
		)
	)::geometry
)
);


-- write angle (deg) into table
update dauz set dauz_tangent_angle = 
	180 / pi() * ST_Azimuth(
		(select (ST_DumpPoints(geom_intersect)).geom order by geom desc limit 1)::geography,
		(select (ST_DumpPoints(geom_intersect)).geom order by geom asc  limit 1)::geography);



select * from dauz order by gps_count_sep2018 desc;

select count (*) from gps_adac_full;

