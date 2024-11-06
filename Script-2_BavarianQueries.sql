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
 
select	(array_agg(fromzone_name))[1] as fromzone_name, -- make the from_zone an array, then only retain 1st element (sic! [1] not [0])
		(array_agg(tozone_name))[1] as tozone_name, -- make the to_zone an array, then only retain 1st element (sic! [1] not [0])		
		array_agg(imp_ttime) as imp_ttime,
		array_agg(imp_distance) as imp_distance,
		array_agg(imp_demand) as imp_demand,
		array_agg(imp_tot_scen1_common) as imp_tot_scen1_common,
		array_agg(imp_tot_scen2_society) as imp_tot_scen2_society,
		array_agg(imp_tot_scen3_technology) as imp_tot_scen3_technology,
		array_agg(imp_tot_scen4_operator) as imp_tot_scen4_operator,
		array_agg(imp_tot_scen5_societyTec) as imp_tot_scen5_societyTec,
		max(u_ample_scen1_common) as u_ample_scen1_common,
		max(u_ample_scen2_society) as u_ample_scen2_society,
		max(u_ample_scen3_technology) as u_ample_scen3_technology,
		max(u_ample_scen4_operator) as u_ample_scen4_operator,
		max(u_ample_scen5_societyTec) as u_ample_scen5_societyTec,
		array_agg(directdist) as directdist,
		ST_GeometryN(ST_Collect(geom_point_fromod), 1) as geom_point_fromod, -- make the from_zone_point (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0]); attention for from_zone_name == from_zone_geom
		ST_GeometryN(ST_Collect(geom_point_tood), 1) as geom_point_tood, -- make the to_zone_point (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0]); attention for from_zone_name == from_zone_geom
		ST_GeometryN(ST_Collect(odconnect), 1) as odconnect -- make the line (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0])
INTO TABLE public.odpair_LVM2035_11856015_onlyBAV_groupedBF --BF: 'Back and Forth'
	FROM public.odpair_LVM2035_23712030_onlyBAV
	group by od_concat;

CREATE INDEX scen1_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen1_common); -- index on affected utility column
CREATE INDEX scen2_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen2_society); -- index on affected utility column
CREATE INDEX scen3_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen3_technology); -- index on affected utility column
CREATE INDEX scen4_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen4_operator); -- index on affected utility column
CREATE INDEX scen5_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen5_societyTec); -- index on affected utility column



select min(u_ample_scen1_common) as min_utility_scen1, avg(u_ample_scen1_common) as avg_utility_scen1, max(u_ample_scen1_common) as max_utility_scen1 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select min(u_ample_scen2_society) as min_utility_scen2, avg(u_ample_scen2_society) as avg_utility_scen2, max(u_ample_scen2_society) as max_utility_scen2 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select min(u_ample_scen3_technology) as min_utility_scen3, avg(u_ample_scen3_technology) as avg_utility_scen3, max(u_ample_scen3_technology) as max_utility_scen3 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select min(u_ample_scen4_operator) as min_utility_scen4, avg(u_ample_scen4_operator) as avg_utility_scen4, max(u_ample_scen4_operator) as max_utility_scen4 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select min(u_ample_scen5_societyTec) as min_utility_scen5, avg(u_ample_scen5_societyTec) as avg_utility_scen5, max(u_ample_scen5_societyTec) as max_utility_scen5 from odpair_LVM2035_11856015_onlyBAV_groupedBF;


--- add possible UAM travel time TODO: Not somewhere in "raw" to be able to play with params in only study area
ALTER TABLE odpair_LVM2035_23712030_onlyBAV ADD COLUMN IF NOT EXISTS ttime_uam_h float8;
ALTER TABLE odpair_LVM2035_23712030_onlyBAV ADD COLUMN IF NOT EXISTS ttime_uam_min float8;

--- params: v_uam = 250km/h
UPDATE LVM_OD_onlyBAV set ttime_uam_min = (directdist / 250) * 60 ;

--- quantiles for each scenario to copy to LaTeX
---- all qantiles and avg/std for scenario 1 (!! Only select, NO 'into...')
select  
  percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common) as scen1_top10, --attention: GroupedBF = 1/2 "onlyBav"
  percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common) as scen1_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common) as scen1_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common) as scen1_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common) as scen1_25perc_top75perc
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select avg(u_ample_scen1_common) as scen1_avg, stddev(u_ample_scen1_common) as scen1_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 2 (!! Only select, NO 'into...')
select  
  percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society) as scen2_top10, --attention: GroupedBF = 1/2 "onlyBav"
  percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society) as scen2_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society) as scen2_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society) as scen2_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society) as scen2_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select avg(u_ample_scen2_society) as scen2_avg, stddev(u_ample_scen2_society) as scen2_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 3 (!! Only select, NO 'into...')
select  
  percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology) as scen3_top10, --attention: GroupedBF = 1/2 "onlyBav"
  percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology) as scen3_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology) as scen3_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology) as scen3_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology) as scen3_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select avg(u_ample_scen3_technology) as scen3_avg, stddev(u_ample_scen3_technology) as scen3_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 4 (!! Only select, NO 'into...')
select  
  percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator) as scen4_top10, --attention: GroupedBF = 1/2 "onlyBav"
  percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator) as scen4_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator) as scen4_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator) as scen4_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator) as scen4_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select avg(u_ample_scen4_operator) as scen4_avg, stddev(u_ample_scen4_operator) as scen4_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 5 (!! Only select, NO 'into...')
select  
  percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec) as scen5_top10, --attention: GroupedBF = 1/2 "onlyBav"
  percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec) as scen5_95perc_top5perc,
  percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec) as scen5_75perc_top25perc,
  percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec) as scen5_50perc_top50perc,
  percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec) as scen5_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select avg(u_ample_scen5_societyTec) as scen4_avg, stddev(u_ample_scen5_societyTec) as scen4_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;





--- make subtable subtables for QGIS visualization; (Q)GIS operations are faster when not working with whole database (only 'public4qgis_...')
-- calculate top percentiles, including top 10 with formula

-- 1111111111111111111111111111111111111111111111111111111
-- Scenario 1: Common scenario (equal weighting)
-- 1111111111111111111111111111111111111111111111111111111

select
  fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p1_common_top10
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create table for top10 (for transfer to LaTeX):
select fromzone_name, tozone_name, least((imp_ttime[1] + imp_distance[1] + imp_demand[1])/3, (imp_ttime[2] + imp_distance[2] + imp_demand[2])/3), * from public4qgis_scen1.u_scen1p1_common_top10 order by u_ample_scen1_common desc;

select * from public4qgis_scen1.u_scen1p1_common_top10 order by u_ample_scen1_common desc;

select
  fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p2_common_top100
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create table for top100 (transfer to LaTeX):
select (imp_ttime[1] + imp_distance[1] + imp_demand[1])/3, * from public4qgis_scen1.u_scen1p2_common_top100 order by u_ample_scen1_common desc;


SELECT
  fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p3_common_top10000
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(9999.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


----EXPERIMENT 
select * from public4qgis_scen1.u_scen1p3_common_top10000 order by u_ample_scen1_common desc;



SELECT ST_ClusterKMeans(odconnect, 96) -- 96 clusters due to number of counties in bavaria
OVER() AS cid, odconnect 
INTO TABLE public4qgis_scen1.u_scen1p3_common_top10000_ClusterKMeans_tempRepro
FROM       public4qgis_scen1.u_scen1p3_common_top10000;


DROP TABLE public4qgis_scen1.u_scen1p3_common_top10000_clusterdbscan_temp;

--SELECT ST_ClusterDBSCAN(ST_pointN(odconnect,1), 10.0, 100)
SELECT ST_ClusterDBSCAN(odconnect, 1.0, 0)
over () AS cid, odconnect
INTO TABLE public4qgis_scen1.u_scen1p3_common_top10000_ClusterDBSCAN_temp
FROM public4qgis_scen1.u_scen1p3_common_top10000;

select count(*) from public4qgis_scen1.u_scen1p3_common_top10000_clusterdbscan_temp where cid=0;
SELECT DISTINCT cid FROM public4qgis_scen1.u_scen1p3_common_top10000_clusterdbscan_temp;

select ST_GeometryType(ST_pointN(odconnect,1)), ST_GeometryType(odconnect) from public4qgis_scen1.u_scen1p3_common_top10000_clusterdbscan_temp;


----EXPERIMENT 

---- Cluster (has to be done as 'last step' to cluster results, not input)
-- Cluster Top 10000 and top 95 percentile, maybe not 'only' 10 or 100 connections

SELECT ST_ClusterKMeans(odconnect, 96) -- 96 clusters due to number of counties in bavaria
OVER() AS cid, odconnect 
INTO TABLE public4qgis_scen1.u_scen1p3_common_top10000_ClusterKMeans
FROM       public4qgis_scen1.u_scen1p3_common_top10000;

-- Get mean ('center') of clusters
SELECT cid, ST_Centroid(ST_Collect(st_centroid(odconnect))) -- double use of 'ST_Centroid to get 'real' mean according to k-means; tested: Resulting points 'very' close together
INTO TABLE public4qgis_scen1.u_scen1p3_common_top10000_ClusterKMeans_centers
FROM       public4qgis_scen1.u_scen1p3_common_top10000_ClusterKMeans
GROUP BY cid ORDER BY cid;

select
  fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p4_common_perc95top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(0.95) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- optional
select
  fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p5_common_perc50top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(0.50) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);



-- 2222222222222222222222222222222222222222222222222222222
-- Scenario 2: Society scenario (weighting on travel time)
-- 2222222222222222222222222222222222222222222222222222222

select
  fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p1_society_top10
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- Top 10 for LaTeX
select * from public4qgis_scen2.u_scen2p1_society_top10 order by u_ample_scen2_society desc;

select
  fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p2_society_top100
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

SELECT
 fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p3_society_top10000
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(9999.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

---- Cluster (has to be done as 'last step' to cluster results, not input)
-- Cluster Top 10000 and top 95 percentile, maybe not 'only' 10 or 100 connections

SELECT ST_ClusterKMeans(odconnect, 96) -- 96 clusters due to number of counties in bavaria
OVER() AS cid, odconnect 
INTO TABLE public4qgis_scen2.u_scen2p3_society_top10000_ClusterKMeans
FROM       public4qgis_scen2.u_scen2p3_society_top10000;

-- Get mean ('center') of clusters
SELECT cid, ST_Centroid(ST_Collect(st_centroid(odconnect))) -- double use of 'ST_Centroid to get 'real' mean according to k-means; tested: Resulting points 'very' close together
INTO TABLE public4qgis_scen2.u_scen2p3_society_top10000_ClusterKMeans_centers
FROM public4qgis_scen2.u_scen2p3_society_top10000_ClusterKMeans
GROUP BY cid ORDER BY cid;

select
  fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p4_society_perc95top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(0.95) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- optional
select
  fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p5_society_perc50top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(0.50) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);



-- 3333333333333333333333333333333333333333333333333333333
-- Scenario 3: Technology scenario (weighting on distance)
-- 3333333333333333333333333333333333333333333333333333333


select
  fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p1_technology_top10
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- Top 10 for LaTeX
select * from public4qgis_scen3.u_scen3p1_technology_top10 order by u_ample_scen3_technology desc;

select
  fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p2_technology_top100
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

SELECT
 fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p3_technology_top10000
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(9999.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

---- Cluster (has to be done as 'last step' to cluster results, not input)
-- Cluster Top 10000 and top 95 percentile, maybe not 'only' 10 or 100 connections

SELECT ST_ClusterKMeans(odconnect, 96) -- 96 clusters due to number of counties in bavaria
OVER() AS cid, odconnect 
INTO TABLE public4qgis_scen3.u_scen3p3_technology_top10000_ClusterKMeans
FROM       public4qgis_scen3.u_scen3p3_technology_top10000;

-- Get mean ('center') of clusters
SELECT cid, ST_Centroid(ST_Collect(st_centroid(odconnect))) -- double use of 'ST_Centroid to get 'real' mean according to k-means; tested: Resulting points 'very' close together
INTO TABLE public4qgis_scen3.u_scen3p3_technology_top10000_ClusterKMeans_centers
FROM public4qgis_scen3.u_scen3p3_technology_top10000_ClusterKMeans
GROUP BY cid ORDER BY cid;

select
  fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p4_technology_perc95top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(0.95) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- optional
select
  fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p5_technology_perc50top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(0.50) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- 444444444444444444444444444444444444444444444444444
-- Scenario 4: Operator scenario (weighting on demand)
-- 444444444444444444444444444444444444444444444444444

select
  fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p1_operator_top10
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- Top 10 for LaTeX
select * from public4qgis_scen4.u_scen4p1_operator_top10 order by u_ample_scen4_operator desc;

select
  fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p2_operator_top100
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

SELECT
 fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p3_operator_top10000
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(9999.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

---- Cluster (has to be done as 'last step' to cluster results, not input)
-- Cluster Top 10000 and top 95 percentile, maybe not 'only' 10 or 100 connections

SELECT ST_ClusterKMeans(odconnect, 96) -- 96 clusters due to number of counties in bavaria
OVER() AS cid, odconnect 
INTO TABLE public4qgis_scen4.u_scen4p3_operator_top10000_ClusterKMeans
FROM       public4qgis_scen4.u_scen4p3_operator_top10000;

-- Get mean ('center') of clusters
SELECT cid, ST_Centroid(ST_Collect(st_centroid(odconnect))) -- double use of 'ST_Centroid to get 'real' mean according to k-means; tested: Resulting points 'very' close together
INTO TABLE public4qgis_scen4.u_scen4p3_operator_top10000_ClusterKMeans_centers
FROM public4qgis_scen4.u_scen4p3_operator_top10000_ClusterKMeans
GROUP BY cid ORDER BY cid;

select
  fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p4_operator_perc95top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(0.95) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- optional
select
  fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p5_operator_perc50top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(0.50) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 555555555555555555555555555555555555555555555555555
-- Scenario 5: SocietyTec scenario ()
-- 555555555555555555555555555555555555555555555555555

select
  fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p1_societytec_top10
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- Top 10 for LaTeX
select * from public4qgis_scen5.u_scen5p1_societytec_top10 order by u_ample_scen5_societytec desc;

select
  fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p2_societytec_top100
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

SELECT
 fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p3_societytec_top10000
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(9999.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

---- Cluster (has to be done as 'last step' to cluster results, not input)
-- Cluster Top 10000 and top 95 percentile, maybe not 'only' 10 or 100 connections

SELECT ST_ClusterKMeans(odconnect, 96) -- 96 clusters due to number of counties in bavaria
OVER() AS cid, odconnect 
INTO TABLE public4qgis_scen5.u_scen5p3_societytec_top10000_ClusterKMeans
FROM       public4qgis_scen5.u_scen5p3_societytec_top10000;

-- Get mean ('center') of clusters
SELECT cid, ST_Centroid(ST_Collect(st_centroid(odconnect))) -- double use of 'ST_Centroid to get 'real' mean according to k-means; tested: Resulting points 'very' close together
INTO TABLE public4qgis_scen5.u_scen5p3_societytec_top10000_ClusterKMeans_centers
FROM public4qgis_scen5.u_scen5p3_societytec_top10000_ClusterKMeans
GROUP BY cid ORDER BY cid;

select
  fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p4_societytec_perc95top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(0.95) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- optional
select
  fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p5_societytec_perc50top
	from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(0.50) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);



select * from public.odpair_LVM2035_11856015_onlyBAV_groupedBF order by u_ample_scen3_technology desc;

