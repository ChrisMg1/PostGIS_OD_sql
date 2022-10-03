SELECT postgis_full_version();

--- names:
DROP TABLE IF exists LVM_OD_996286

-- create and specify table
create table LVM_OD_996286 (
FROMZONE_NO int,
FROMZONE_NAME text,
FROMZONE_XCOORD float,
FROMZONE_YCOORD float,
FROMZONE_AGS text,
FROMZONE_AKS int,
FROMZONE_BY bool,
TOZONE_NO int,
TOZONE_NAME text,
TOZONE_XCOORD float,
TOZONE_YCOORD float,
TOZONE_AGS text,
TOZONE_AKS int,
TOZONE_BY bool,
DIRECTDIST float,
TTime_PrT float,
TTime_PuT float,
Demand_Pkw float,
Demand_PkwM float,
Demand_PuT float,
Demand_Bike float,
Demand_Walk float,
Demand_all float,
Demand_IVOEV float,
beeline_speed_PuT_kmh float,
TTime_ratio float
)

--- import csv
COPY LVM_OD_996286
FROM 'C:\temp\test4.csv' 
DELIMITER E'\t'
ENCODING 'UTF8'
CSV HEADER;



--- Adapt strcuture to existing scripts
-- 'new' columns: demand_pkwbusy

-- rename columns
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "fromzoneno" TO "fromzone_no";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "tozoneno" TO "tozone_no";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\NAME" TO "fromzone_name";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\XCOORD" TO "fromzone_xcoord";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\YCOORD" TO "fromzone_ycoord";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\B_AGS" TO "fromzone_ags";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\B_AKS" TO "fromzone_aks";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\B_BAYERN" TO "fromzone_by";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\NAME" TO "tozone_name";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\XCOORD" TO "tozone_xcoord";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\YCOORD" TO "tozone_ycoord";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\B_AGS" TO "tozone_ags";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\B_AKS" TO "tozone_aks";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\B_BAYERN" TO "tozone_by";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "directdist" TO "directdist";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(116)" TO "ttime_prt";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(309)" TO "ttime_put";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(1)" TO "demand_pkw";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(2)" TO "demand_pkwm";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(21)" TO "demand_pkwbusy";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(3)" TO "demand_put";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(4)" TO "demand_bike";
ALTER TABLE odpair_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(5)" TO "demand_walk";

--- add the necessary tables for metrics (that were once created using python)
ALTER TABLE odpair_fromSQLite_44342281_raw
	add column IF NOT EXISTS demand_all float8,
	add column IF NOT EXISTS demand_ivoev float8,
	add column IF NOT EXISTS beeline_speed_put_kmh float8,
	add column IF NOT EXISTS ttime_ratio float8;

-- attention for "division by zero"; handled by python (set to NULL)
update odpair_fromSQLite_44342281_raw set
	demand_all = demand_pkw + demand_pkwm + demand_put + demand_bike + demand_walk,
	demand_ivoev = demand_pkw + demand_pkwm + demand_put,
	beeline_speed_put_kmh = 60 * (directdist / NULLIF(ttime_put, 0)),
	ttime_ratio = ttime_put / NULLIF(ttime_prt, 0);



--- Table names: odpair_fromSQLite_44342281_raw | lvm_od_996286
			
-- add geometry columns (points and line)
ALTER TABLE odpair_fromSQLite_44342281_raw
	ADD COLUMN IF NOT EXISTS geom_point_fromOD geometry(Point),
	ADD COLUMN IF NOT EXISTS geom_point_toOD geometry(Point),
	ADD COLUMN IF NOT EXISTS ODconnect geometry(Linestring);
	
	
	-- ADD COLUMN IF NOT EXISTS allpoints geometry(Point); -- planned as merge/union to have all start/end-points only once. 

-- fill geometry columns
-- Bayern is UTM32 is 32632 im LVM-export (old and 'official' EPSG:25832)
UPDATE odpair_fromSQLite_44342281_raw SET
	geom_point_fromOD = st_setsrid(st_makepoint(fromzone_xcoord, fromzone_ycoord), 32632),
	geom_point_toOD = st_setsrid(st_makepoint(tozone_xcoord, tozone_ycoord), 32632);

-- maybe make it in one query for performance reasons (line impossible before points??)
UPDATE odpair_fromSQLite_44342281_raw set
	
	demand_all = demand_pkw + demand_pkwm + demand_put + demand_bike + demand_walk,
	demand_ivoev = demand_pkw + demand_pkwm + demand_put;


--- SUBTABLE: rebuilt the original import with demand >= 1
drop table LVM_OD_996286_recap;

SELECT *
INTO TABLE LVM_OD_996286_recap
FROM odpair_fromSQLite_44342281_raw
where demand_ivoev >= 1;

--- SUBTABLE: Only inner-Bavaria connections; demand >= 0
drop table LVM_OD_onlyBAV;

SELECT * INTO TABLE LVM_OD_onlyBAV
	FROM odpair_fromSQLite_44342281_raw
	where fromzone_by = 1
	and tozone_by = 1;

--- get rid of the negative demand values
UPDATE LVM_OD_onlyBAV SET
	demand_pkw = GREATEST(0, demand_pkw),
	demand_pkwm = GREATEST(0, demand_pkwm),
	demand_put = GREATEST(0, demand_put),
	demand_bike = GREATEST(0, demand_bike),
	demand_walk = GREATEST(0, demand_walk);

UPDATE LVM_OD_onlyBAV SET
	demand_all = demand_pkw + demand_pkwm + demand_put + demand_bike + demand_walk,
	demand_ivoev = demand_pkw + demand_pkwm + demand_put;

--- add possible UAM travel time TODO: Add somewhere in "raw"
ALTER TABLE LVM_OD_onlyBAV ADD COLUMN IF NOT EXISTS ttime_uam_h float8;
ALTER TABLE LVM_OD_onlyBAV ADD COLUMN IF NOT EXISTS ttime_uam_min float8;
--- params: v_uam = 250km/h
UPDATE LVM_OD_onlyBAV set ttime_uam_min = (directdist / 250) * 60 ;


---some selects
SELECT distinct fromzone_by FROM odpair_fromSQLite_44342281_raw;
select count(*) from odpair_fromSQLite_44342281_raw 
	where demand_ivoev >= 1 and fromzone_by = 1 and tozone_by = 1 and fromzone_no != tozone_no;

select * from LVM_OD_onlyBAV where fromzone_no != tozone_no order by pax_h_base desc;
select * from LVM_OD_onlyBAV where fromzone_no != tozone_no order by pax_h_uam_all desc;

select * from LVM_OD_onlyBAV where fromzone_no != tozone_no and pax_h_base = pax_h_uam_all;

select count(*) from LVM_OD_onlyBAV;
select count(*) from LVM_OD_onlyBAV where (ttime_put = ttime_uam_min);
select count(*) from LVM_OD_onlyBAV where (ttime_prt = ttime_uam_min);

