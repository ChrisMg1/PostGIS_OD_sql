-- create table

create table GPS_asset_two (
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
lastlatitude float8,
lastlongitude float8,
latitude float8,
longitude float8,
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
velocity float8
)

create table dauz (
longitude float8,
latitude float8,
BASt_ID int,
name text,
road text,
Abschnitt int,
Station int,
some_bool bool,
url text
)

CREATE TABLE IF NOT EXISTS foo ...;

UPDATE dauz SET gps_count_sep2018 = 1 where bast_id = 9276;

CREATE TABLE table2 AS SELECT * FROM gps_adac_full WHERE 1=2; 

select * from gps_asset_one where timestamputc = '2018-09-14 16:11:13' order by ctid desc;


select ctid, oid from gps_asset_one;

DELETE
FROM
    gps_asset_one a
        USING gps_asset_one b
WHERE
    a.ctid < b.ctid
    AND a.timestamputc = b.timestamputc and a.latitude = b.latitude;
   
   
ALTER TABLE gps_asset_one ADD PRIMARY KEY (timestamputc);

select ctid, * from gps_asset_one;


-- Firstly, remove PRIMARY KEY attribute of former PRIMARY KEY
ALTER table gps_asset_one DROP CONSTRAINT gps_asset_one_pkey;

-- Then change column name of  your PRIMARY KEY and PRIMARY KEY candidates properly.
ALTER TABLE around_dauz_9407 add column my_angle int;
select timestamputc into id2 from gps_asset_one;
-- ALTER TABLE <table_name> RENAME COLUMN <primary_key_candidate> TO id;

select direction from gps_asset_one order by direction desc;
update around_dauz_9407 set my_angle = direction / 10;

-- Lastly set your new PRIMARY KEY
ALTER TABLE gps_asset_one ADD PRIMARY KEY (id);
   
select * from gps_asset_two;  

CREATE INDEX id_index ON gps_adac_full (assetid);
CREATE INDEX geom_index ON admarea_gemeinde using gist (geom);
SELECT * into gps_asset_six FROM gps_adac_full WHERE assetid = '00003602';
   