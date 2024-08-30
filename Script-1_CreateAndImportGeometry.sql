SELECT postgis_full_version();
SELECT version(); ---PostgreSQL only
select sqlite_version(); ---sqlite only

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
Demand_Walk float
)

--- import csv
COPY LVM_OD_996286
FROM 'C:\temp\test4.csv' 
DELIMITER E'\t'
ENCODING 'UTF8'
CSV HEADER;

--- Oder aus sqlite WIederherstellen: Im DBeaver bei der sqlite auf Export (ODPAIR), dann "multiple fetch" und Ziel ist dann die postgres-Datenbank, Port :5432

--- Adapt strcuture to existing scripts
-- 'new' columns: demand_pkwbusy

-- rename columns
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "fromzoneno" TO "fromzone_no";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "tozoneno" TO "tozone_no";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\NAME" TO "fromzone_name";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\XCOORD" TO "fromzone_xcoord";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\YCOORD" TO "fromzone_ycoord";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\B_AGS" TO "fromzone_ags";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\B_AKS" TO "fromzone_aks";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "FROMZONE\B_BAYERN" TO "fromzone_by";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\NAME" TO "tozone_name";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\XCOORD" TO "tozone_xcoord";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\YCOORD" TO "tozone_ycoord";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\B_AGS" TO "tozone_ags";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\B_AKS" TO "tozone_aks";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "TOZONE\B_BAYERN" TO "tozone_by";
--ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "directdist" TO "directdist"; ---[km]
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(116)" TO "ttime_prt"; ---[min]
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(309)" TO "ttime_put"; ---[min]
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(1)" TO "demand_pkw";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(2)" TO "demand_pkwm";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(21)" TO "demand_pkwbusy"; --- Personenwirtschaftsverkehr?
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(3)" TO "demand_put";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(4)" TO "demand_bike";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(5)" TO "demand_walk";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(11)" TO "demand_hgv_lt3p5";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(12)" TO "demand_hgv_lt7p5";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(13)" TO "demand_hgv_lt12p5";
ALTER TABLE odpair_2035_fromSQLite_44342281_raw RENAME COLUMN "MATVALUE(14)" TO "demand_hgv_gt12p5";

--- add the necessary tables for metrics (that were once created using python)
ALTER TABLE odpair_2035_fromSQLite_44342281_raw
	add column IF NOT EXISTS demand_all_person float8,
	add column IF NOT EXISTS demand_all_person_purged float8,
	add column IF NOT EXISTS demand_ivoev_purged float8,
	add column IF NOT EXISTS beeline_speed_put_kmh float8,
	add column IF NOT EXISTS ttime_ratio float8;

-- attention for "division by zero"; handled by python (set to NULL)
update odpair_2035_fromSQLite_44342281_raw set
	demand_all_person = demand_pkw + demand_pkwm + demand_put + demand_bike + demand_walk,
	demand_all_person_purged = GREATEST(0, demand_pkw) + GREATEST(0, demand_pkwm) + GREATEST(0, demand_put) + GREATEST(0, demand_bike) + GREATEST(0, demand_walk), --- get rid of the negative demand values (from calibration)
	demand_ivoev_purged = GREATEST(0, demand_pkw) + GREATEST(0, demand_pkwm) + GREATEST(0, demand_put),
	beeline_speed_put_kmh = 60 * (directdist / NULLIF(ttime_put, 0)),
	ttime_ratio = NULLIF(ttime_put, 0) / NULLIF(ttime_prt, 0);

SELECT count(*) FROM odpair_2035_fromsqlite_44342281_raw
	where fromzone_by = 1
	and tozone_by = 1
	and fromzone_no != tozone_no;

SELECT * INTO TABLE odpair_LVM2035_23712030_onlyBAV
	FROM odpair_2035_fromsqlite_44342281_raw
	where fromzone_by = 1
	and tozone_by = 1
	and fromzone_no != tozone_no;

CREATE INDEX onlyBAV_index_ttratio ON public.odpair_LVM2035_23712030_onlyBAV(ttime_ratio);
CREATE INDEX onlyBAV_index_ttput ON public.odpair_LVM2035_23712030_onlyBAV(ttime_put);

CREATE INDEX onlyBAV_index_ttprt ON public.odpair_LVM2035_23712030_onlyBAV(ttime_prt);

select * from odpair_LVM2035_23712030_onlyBAV order by ttime_ratio desc;
select count(*) from odpair_LVM2035_23712030_onlyBAV where ttime_ratio is null;


--- Select row with max in a specific column
SELECT * FROM odpair_2035_fromsqlite_44342281_raw
	WHERE "demand_all_person" = ( SELECT max("demand_all_person") FROM odpair_2035_fromsqlite_44342281_raw );

SELECT * FROM odpair_2035_fromsqlite_44342281_raw where demand_pkw < 0 or demand_pkwm < 0 or demand_put < 0 or demand_bike < 0 or demand_walk < 0 order by demand_pkw asc;
SELECT count(*) FROM odpair_2035_fromsqlite_44342281_raw where demand_pkw < 0 or demand_pkwm < 0 or demand_put < 0 or demand_bike < 0 or demand_walk < 0;

SELECT * FROM odpair_LVM2035_23712030_onlyBAV order by imp_tot_scen1_common desc;

--- export csv (e.g. for histogram); run python script after this steps
-- todo: One single export; no split for plots
COPY odpair_lvm2035_23712030_onlybav(ttime_put, ttime_prt, ttime_ratio, imp_ttime, directdist, imp_distance, demand_all_person_purged, imp_demand, imp_tot_scen1_common, imp_tot_scen2_society, imp_tot_scen3_technology, imp_tot_scen4_operator) TO 'C:\TUMdissDATA\odpair_lvm2035_23712030_onlybav_exp.csv' DELIMITER ',' CSV HEADER; -- integrate demand, purged demand for full export
COPY odpair_lvm2035_11856015_onlybav_groupedbf(u_ample_scen1_common, u_ample_scen2_society, u_ample_scen3_technology, u_ample_scen4_operator) TO 'C:\TUMdissDATA\odpair_lvm2035_23712030_onlybav_groupedBF_exp.csv' DELIMITER ',' CSV HEADER;

COPY odpair_2035_fromsqlite_44342281_raw(fromzone_by, tozone_by, fromzone_no, tozone_no, demand_pkw, demand_pkwm, demand_put, demand_bike, demand_walk, demand_all_person, demand_all_person_purged) TO 'C:\TUMdissDATA\demandWITHbavariaFLAG2.csv' DELIMITER ',' CSV HEADER;
COPY odpair_2035_fromsqlite_44342281_raw(demand_pkw, demand_pkwm, demand_put, demand_bike, demand_walk) TO 'C:\TUMdissDATA\demandPERmodeNOod.csv' DELIMITER ',' CSV HEADER;

