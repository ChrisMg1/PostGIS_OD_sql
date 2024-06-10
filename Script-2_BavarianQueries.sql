--- here only querys for bavarian table
--- export: Prepare data in database cm_UAM2035fromSQLite, table odpair_2035_fromsqlite_44342281_raw
--- export to odpair_lvm2035_23716900_onlybav
---- filter: only bav taz's
---- filter: from != to
--- finally transfer to new database xyz



-- add geometry columns (points and line)
ALTER TABLE odpair_LVM2035_23712030_onlyBAV
	ADD COLUMN IF NOT EXISTS geom_point_fromOD geometry(Point),
	ADD COLUMN IF NOT EXISTS geom_point_toOD geometry(Point),
	ADD COLUMN IF NOT EXISTS ODconnect geometry(Linestring);
	
	
-- ADD COLUMN IF NOT EXISTS allpoints geometry(Point); -- planned as merge/union to have all start/end-points only once. 

--- fill geometry columns
-- Bayern is UTM32 is 32632 im LVM-export (old and 'official' EPSG:25832)
UPDATE odpair_LVM2035_23712030_onlyBAV SET
	geom_point_fromOD = st_setsrid(st_makepoint(fromzone_xcoord, fromzone_ycoord), 32632),
	geom_point_toOD = st_setsrid(st_makepoint(tozone_xcoord, tozone_ycoord), 32632);


UPDATE odpair_LVM2035_23712030_onlyBAV
	set	ODconnect = st_makeline(geom_point_fromOD, geom_point_toOD);

--- Create geometry indexes
	
CREATE INDEX fromOD_geom_idx
  ON odpair_LVM2035_23712030_onlyBAV
  USING GIST (geom_point_fromOD);
 
CREATE INDEX toOD_geom_idx
  ON odpair_LVM2035_23712030_onlyBAV
  USING GIST (geom_point_toOD);
 
CREATE INDEX conn_geom_idx
  ON odpair_LVM2035_23712030_onlyBAV
  USING GIST (ODconnect);


select * from odpair_LVM2035_23712030_onlyBAV order by od_concat asc;

-- Merge back-and-forth connections for _final evaluation_
--- 0) Create Column
ALTER TABLE odpair_LVM2035_23712030_onlyBAV ADD COLUMN IF NOT EXISTS od_concat text;
--- 1) Concatenate
UPDATE odpair_LVM2035_23712030_onlyBAV set
	od_concat = CONCAT(LEAST(fromzone_no, tozone_no), '-', GREATEST(fromzone_no, tozone_no));

---1.1) Index
CREATE EXTENSION btree_gist;

CREATE INDEX od_merge_idx
  ON odpair_LVM2035_23712030_onlyBAV
  USING GIST (od_concat);

--- 2) Merge into new table --TODO, TEST at the moment, merge by avg(U) in the end
SELECT COUNT(*) FROM (SELECT DISTINCT od_concat FROM odpair_LVM2035_23712030_onlyBAV) AS temp; --first: count possible/future rows
 
SELECT max(fromzone_name) as fromzone_name_gd, min(tozone_name) as tozone_name_gd, max(directdist) as directdist_gd, max(odconnect) as odconnect_gd INTO TABLE odpair_LVM2035_11856015_onlyBAV_grouped --index _gd stands for "grouped"; TODO: index weg; TODO: avg(ample)
	FROM odpair_LVM2035_23712030_onlyBAV
	group by od_concat;

select * from odpair_lvm2035_11856015_onlybav_grouped;


--- add possible UAM travel time TODO: Not somewhere in "raw" to be able to play with params in only study area
ALTER TABLE LVM_OD_onlyBAV ADD COLUMN IF NOT EXISTS ttime_uam_h float8;
ALTER TABLE LVM_OD_onlyBAV ADD COLUMN IF NOT EXISTS ttime_uam_min float8;

--- params: v_uam = 250km/h
UPDATE LVM_OD_onlyBAV set ttime_uam_min = (directdist / 250) * 60 ;

--- quantiles for each scenario to copy to LaTeX
---- all qantiles and avg/std for scenario 1
select  
  percentile_disc(1.0-(9.0 / 23712030.0)) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen1_common) as scen1_top10,
  percentile_disc(0.95) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen1_common) as scen1_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen1_common) as scen1_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen1_common) as scen1_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen1_common) as scen1_25perc_top75perc  
from odpair_lvm2035_23712030_onlybav;
select avg(u_ample_scen1_common) as scen1_avg, stddev(u_ample_scen1_common) as scen1_stddev from odpair_lvm2035_23712030_onlybav;

---- all qantiles and avg/std for scenario 2
select  
  percentile_disc(1.0-(9.0 / 23712030.0)) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen2_society) as scen2_top10,
  percentile_disc(0.95) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen2_society) as scen2_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen2_society) as scen2_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen2_society) as scen2_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen2_society) as scen2_25perc_top75perc  
from odpair_lvm2035_23712030_onlybav;
select avg(u_ample_scen2_society) as scen2_avg, stddev(u_ample_scen2_society) as scen2_stddev from odpair_lvm2035_23712030_onlybav;

---- all qantiles and avg/std for scenario 3
select  
  percentile_disc(1.0-(9.0 / 23712030.0)) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen3_technology) as scen3_top10,
  percentile_disc(0.95) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen3_technology) as scen3_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen3_technology) as scen3_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen3_technology) as scen3_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen3_technology) as scen3_25perc_top75perc  
from odpair_lvm2035_23712030_onlybav;
select avg(u_ample_scen3_technology) as scen3_avg, stddev(u_ample_scen3_technology) as scen3_stddev from odpair_lvm2035_23712030_onlybav;

---- all qantiles and avg/std for scenario 4
select  
  percentile_disc(1.0-(9.0 / 23712030.0)) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen4_operator) as scen4_top10,
  percentile_disc(0.95) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen4_operator) as scen4_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen4_operator) as scen4_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen4_operator) as scen4_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_lvm2035_23712030_onlybav.u_ample_scen4_operator) as scen4_25perc_top75perc  
from odpair_lvm2035_23712030_onlybav;
select avg(u_ample_scen4_operator) as scen4_avg, stddev(u_ample_scen4_operator) as scen4_stddev from odpair_lvm2035_23712030_onlybav;



select count(*) from odpair_lvm2035_23712030_onlybav where u_ample_scen3_technology >= 0.890911215269049;

--- make subtables for QGIS visualization
select
  fromzone_name, tozone_name, directdist, u_ample_scen4_operator, odconnect
INTO TABLE u_perc95top_scen4p2_operator
from odpair_LVM2035_23712030_onlyBAV
where u_ample_scen4_operator >= 
 (select
  percentile_disc(0.95) within group (order by u_ample_scen4_operator asc) as percentile
 from odpair_LVM2035_23712030_onlyBAV);
 
-- determine percentile for table overview in LaTeX
select percentile_disc(0.95) within group (order by u_ample_scen4_operator asc) as percentile from odpair_LVM2035_23712030_onlyBAV;

SELECT * FROM odpair_lvm2035_23712030_onlybav order by u_ample_scen4_operator desc;

