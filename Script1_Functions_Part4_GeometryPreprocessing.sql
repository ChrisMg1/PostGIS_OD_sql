-- This script prepares the table for geometry evaluations
--- It adds geom columns
--- It makes an unique identifier for all connections (i.e. back and forth)

--- can regularily be skipped, as 'odpair_LVM2035_23712030_onlyBAV_restored' is already prepared

-- add geometry columns (points and line)
ALTER TABLE odpair_LVM2035_23712030_onlyBAV_restored
	ADD COLUMN IF NOT EXISTS geom_point_fromOD geometry(Point),
	ADD COLUMN IF NOT EXISTS geom_point_toOD geometry(Point),
	ADD COLUMN IF NOT EXISTS ODconnect geometry(Linestring),
	ADD COLUMN IF NOT EXISTS od_concat text;
	
	
-- ADD COLUMN IF NOT EXISTS allpoints geometry(Point); -- planned as merge/union to have all start/end-points only once. 

--- fill geometry columns
-- Bayern is UTM32 is 32632 im LVM-export (old and 'official' EPSG:25832)
UPDATE odpair_LVM2035_23712030_onlyBAV_restored SET
	geom_point_fromOD = st_setsrid(st_makepoint(fromzone_xcoord, fromzone_ycoord), 32632),
	geom_point_toOD = st_setsrid(st_makepoint(tozone_xcoord, tozone_ycoord), 32632);

UPDATE odpair_LVM2035_23712030_onlyBAV_restored
	set	ODconnect = st_makeline(geom_point_fromOD, geom_point_toOD);




-- Merge back-and-forth connections for _final evaluation_
--- 1) Concatenate
UPDATE odpair_LVM2035_23712030_onlyBAV_restored set
	od_concat = CONCAT(LEAST(fromzone_no, tozone_no), '-', GREATEST(fromzone_no, tozone_no));

---1.1) Index
CREATE EXTENSION btree_gist;

CREATE INDEX od_merge_idx
  ON odpair_LVM2035_23712030_onlyBAV_restored
  USING GIST (od_concat);
--- Create geometry indexes
	
CREATE INDEX fromOD_geom_idx
  ON odpair_LVM2035_23712030_onlyBAV_restored
  USING GIST (geom_point_fromOD);
 
CREATE INDEX toOD_geom_idx
  ON odpair_LVM2035_23712030_onlyBAV_restored
  USING GIST (geom_point_toOD);
 
CREATE INDEX conn_geom_idx
  ON odpair_LVM2035_23712030_onlyBAV_restored
  USING GIST (ODconnect);

