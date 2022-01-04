--- names:
LVM_OD_996286


-- create and specify table
create table LVM_OD_996286 (
FROMZONE_NO int,
FROMZONE_NAME text,
FROMZONE_XCOORD float,
FROMZONE_YCOORD float,
FROMZONE_AGS text,
FROMZONE_AKS int,
FROMZONE_BY int,
TOZONE_NO int,
TOZONE_NAME text,
TOZONE_XCOORD float,
TOZONE_YCOORD float,
TOZONE_AGS text,
TOZONE_AKS int,
TOZONE_BY int,
DIRECTDIST float,
Time_PrT float,
Time_PuT float,
Demand_Pkw float,
Demand_PkwM float,
Demand_PuT float,
Demand_Bike float,
Demand_Walk float,
Demand_all float,
Demand_IVOEV float,
beeline_speed_PuT float,
speed_ratio float
)

--- import csv
COPY LVM_OD_996286
FROM 'C:\temp\test4.csv' 
DELIMITER E'\t'
ENCODING 'UTF8'
CSV HEADER;




---check length
SELECT
   COUNT(*) 
FROM 
   LVM_OD_996286;
  
  
---check content
SELECT
   *
FROM 
   LVM_OD_996286;

create table GPS_full (
assetId text,
country text,
created text,
direction int,
distfrom text,
district text,
distto text,
federalstate text,
forwardDir text,
isdirectionvalid text,
lastlatitude int,
lastlongitude int,
latitude int,
longitude int,
oid text,
poshint text,
providerId text,
status text,
timestamputc timestamp,
tmc_latitude text,
tmc_longitude text,
tmcsegmentid text,
town text,
vehicletype text,
velocity int
)
