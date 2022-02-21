
			
-- add geometry columns (points and line)
ALTER TABLE lvm_od_996286
ADD COLUMN geom_point_fromOD geometry(Point),
ADD COLUMN geom_point_toOD geometry(Point),
ADD COLUMN ODconnect geometry(Linestring);

-- fill geometry columns
-- Bayern is UTM32 is EPSG:25832
UPDATE lvm_od_996286
set geom_point_fromOD = st_setsrid(st_makepoint(fromzone_xcoord, fromzone_ycoord), 25832);

UPDATE lvm_od_996286
set geom_point_toOD = st_setsrid(st_makepoint(tozone_xcoord, tozone_ycoord), 25832);

UPDATE lvm_od_996286
set	ODconnect = st_makeline(geom_point_fromOD, geom_point_toOD);

-- https://de.wikipedia.org/wiki/Liste_der_Verkehrs-_und_Sonderlandepl%C3%A4tze_in_Deutschland
UPDATE air_shp
set geom = st_setsrid(st_makepoint(cm_lon, cm_lat), 4326);

ALTER TABLE air_shp
RENAME TO Verkehrs_und_Sonderlandeplaetze;

select * from Verkehrs_und_Sonderlandeplaetze_BY;
select * from "Verkehrsflughaefen";
select * from "dt_test";

SELECT Find_SRID('public', 'verkehrs_und_sonderlandeplaetze_by', 'geom');
SELECT Find_SRID('public', 'lvm_od_996286', 'geom_point_tood');
SELECT ST_SRID(select top 1 geom from verkehrs_und_sonderlandeplaetze_by);
select * from "Verkehrsflughaefen";

select *
into table Verkehrs_und_Sonderlandeplaetze_BY
from Verkehrs_und_Sonderlandeplaetze
where "bundes-lan" = 'BY';



-- change crs for affected layers

ALTER TABLE Verkehrs_und_Sonderlandeplaetze_BY
  ALTER COLUMN geom 
  TYPE Geometry(Point, 25832) 
  USING ST_Transform(geom, 25832);
 
ALTER TABLE "Verkehrsflughaefen"
  ALTER COLUMN geom 
  TYPE Geometry(Point, 25832) 
  USING ST_Transform(geom, 25832);


select * from nearest_airport;

ALTER TABLE nearest_airport
ADD COLUMN geom2 geometry(Linestring);

update nearest_airport
set geom2 = st_makeline(st_setsrid(st_makepoint(feature_x, feature_y), 25832), st_setsrid(st_makepoint(nearest_x, nearest_y), 25832) );

