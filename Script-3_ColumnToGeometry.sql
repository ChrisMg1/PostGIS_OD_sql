-- count entries
select count(*) from lvm_od_996286;
			
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



