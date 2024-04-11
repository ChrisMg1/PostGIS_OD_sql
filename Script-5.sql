select * 
into gps_assetone_sub
from gps_assetone
where lat2 < 49.502440

select distinct assetid
into gps_assetone_sub_dist
from gps_assetone
where lat2 < 49.502440

select * from gps_asset_one limit 100

select * from dauz;

select geom from strassen_polyline2;

select latitude from dauz where bast_id = 9041;

select longitude from dauz where bast_id = 9041;

@set tempdauz = 9552;

SELECT * 
	into temp_dauz_9407
	FROM around_dauz_9407 
	WHERE ST_DWithin(geom, ST_MakePoint(
		(select longitude from dauz where bast_id = :dauz),
		(select latitude from dauz where bast_id = :dauz) )::geography, 
		100); 

	
SELECT * 
	into temp_dauz_9407_6
	FROM around_dauz_9407 
	WHERE (abs((((select dauz_tangent_angle from dauz where bast_id = 9407) + 360)::int % 360 ) - my_angle) % 180) < 40; 
	
	
	
	
SELECT * into gps_adac_full_WITH_PRIMARY from gps_adac_full;

SELECT COUNT (DISTINCT assetid) FROM gps_adac_full;
-- count: 1.435.472

SELECT COUNT (*) FROM gps_adac_full;

select DISTINCT assetid from gps_adac_full;

SELECT COUNT (DISTINCT vehicletype) FROM gps_adac_full;
-- count: 4

SELECT COUNT (*) FROM my_points;
--179,165,055

select COUNT (DISTINCT distfrom) from gps_asset_one;

select * from od_matrix where from_gs = to_gs and gps_points < 500 order by gps_points desc;

select * into gps_asset_EE676A75_Binnen from gps_adac_full where assetid = 'EE676A75';

drop table gps_asset_EE676A75_binnen;

select ctid from gps_asset_EE676A75_binnen;


DELETE
FROM
    gps_asset_EE676A75_Binnen a
        USING gps_asset_EE676A75_Binnen b
WHERE
    a.ctid < b.ctid
    AND a.timestamputc = b.timestamputc and a.latitude = b.latitude;
   
   

alter table gps_asset_EE676A75_Binnen add primary key (timestamputc);
select *, primary key from gps_asset_EE676A75_Binnen;



select dauz_tangent_angle from dauz;

select geom from my_polygon;

select ST_DumpPoints(geom) as my_export into my_temp2 from my_polygon;
select * from my_temp2;

SELECT (my_export).geom into my_points2 from my_temp2;

select * from my_points;
SELECT COUNT (DISTINCT geom) FROM my_points;


 SELECT DISTINCT ON (dauz.bast_id) dauz.bast_id, strassen_polyline2.abs, ST_Distance(ST_SetSRID(ST_Makepoint(p.x, p.y),4326), dauz.geom)
FROM points dauz
    LEFT JOIN roads r ON ST_DWithin(ST_SetSRID(ST_Makepoint(p.x, p.y),4326), r.geom, 30.48)
ORDER BY p.id, ST_Distance(ST_SetSRID(ST_Makepoint(p.x, p.y),4326), r.geom);


