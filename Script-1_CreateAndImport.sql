
-- create and specify table
create table LVM_OD (
FROMZONE_NO int,
FROMZONE_NAME text,
FROMZONE_XCOORD float,
FROMZONE_YCOORD float,
TOZONE_NO int,
TOZONE_NAME text,
TOZONE_XCOORD float,
TOZONE_YCOORD float,
DIRECTDIST float,
Time_PrT float,
Time_PuT float,
Demand_Pkw float,
Demand_PkwM float,
Demand_PuT float,
Demand_all float,
beeline_speed float,
speed_ratio float,
wkt_geom text
)

--- import csv
COPY lvm_od
FROM 'C:\temp\test.csv' 
DELIMITER E'\t' 
CSV HEADER;



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
