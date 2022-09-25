--- names:
DROP TABLE IF exists LVM_OD_996286

SELECT usename AS role_name,
  CASE 
     WHEN usesuper AND usecreatedb THEN 
	   CAST('superuser, create database' AS pg_catalog.text)
     WHEN usesuper THEN 
	    CAST('superuser' AS pg_catalog.text)
     WHEN usecreatedb THEN 
	    CAST('create database' AS pg_catalog.text)
     ELSE 
	    CAST('' AS pg_catalog.text)
  END role_attributes
FROM pg_catalog.pg_user
ORDER BY role_name desc;

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

create table UAM_TEST (
FROMZONE_NO int,
TOZONE_NO int,
DIRECTDIST float,
TTime_PrT float,
TTime_PuT float,
Demand_PrT float,
Demand_PuT float,
beeline_speed_PuT_kmh float,
TTime_ratio float,
R_scen_1 float,
R_scen_2 float,
R_scen_3 float
)

--- import csv
COPY LVM_OD_996286
FROM 'C:\temp\test4.csv' 
DELIMITER E'\t'
ENCODING 'UTF8'
CSV HEADER;

-- check length
SELECT count(*) from LVM_OD_996286;-- where fromzone_no = tozone_no;




  
  