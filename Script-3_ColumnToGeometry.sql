
			
-- add geometry columns (points and line)
ALTER TABLE lvm_od_996286
ADD COLUMN geom_point_fromOD geometry(Point),
ADD COLUMN geom_point_toOD geometry(Point),
ADD COLUMN ODconnect geometry(Linestring);

-- fill geometry columns
-- Bayern is UTM32 is 32632 im LVM-export (old and 'official' EPSG:25832)
UPDATE lvm_od_996286
set geom_point_fromOD = st_setsrid(st_makepoint(fromzone_xcoord, fromzone_ycoord), 32632);

UPDATE lvm_od_996286
set geom_point_toOD = st_setsrid(st_makepoint(tozone_xcoord, tozone_ycoord), 32632);

UPDATE lvm_od_996286
set	ODconnect = st_makeline(geom_point_fromOD, geom_point_toOD);


-- Subset on Bavaria
select *
into table Verkehrs_und_Sonderlandeplaetze_BY
from verkehrs_und_sonder_parsed
where "bundes-land" = 'BY';

select *
into table segelflug_by
from "Segelflug_parsed"
where "bundesland" = 'Bayern';


-- fit coordinate systems
ALTER TABLE verkehrs_und_sonder_parsed
  ALTER COLUMN geom 
  TYPE Geometry(Point, 32632) 
  USING ST_Transform(geom, 32632);
 
ALTER TABLE "Segelflug_parsed"
 ALTER COLUMN geom 
 TYPE Geometry(Point, 32632) 
 USING ST_Transform(geom, 32632);

ALTER TABLE "Verkehrsflughaefen"
 ALTER COLUMN geom 
 TYPE Geometry(Point, 32632) 
 USING ST_Transform(geom, 32632);

ALTER TABLE "lkr_ex_by"
 ALTER COLUMN geom 
 TYPE Geometry(MultiPolygon, 32632) 
 USING ST_Transform(geom, 32632);


ALTER TABLE nearest_airport
ADD COLUMN geom2 geometry(Linestring);

ALTER TABLE nearest_airport
DROP COLUMN geom;

update nearest_airport
set geom2 = st_makeline(st_setsrid(st_makepoint(feature_x, feature_y), 32632), st_setsrid(st_makepoint(nearest_x, nearest_y), 32632) );

