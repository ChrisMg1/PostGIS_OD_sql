--- this script
-- 1) Groups the connections to 'back-and-firth ('BF')
-- 2) make subtable subtables (i.e. schemas) for QGIS visualization; (Q)GIS operations are faster when not working with whole database (only 'public4qgis_...')
-- calculate top percentiles, including top 10 with formula

--- this 'select into' has to be run after every update of impedances or utilities AND preceding update of 'odpair_LVM2035_11856015_onlyBAV_groupedBF'
-- takes only 6 minutes ca. 

--DROP TABLE IF EXISTS public.odpair_LVM2035_11856015_onlyBAV_groupedBF_saveCOPY CASCADE;

--CREATE TABLE public.odpair_LVM2035_11856015_onlyBAV_groupedBF_saveCOPY AS
--SELECT * FROM public.odpair_LVM2035_11856015_onlyBAV_groupedBF;

DROP TABLE IF EXISTS public.odpair_LVM2035_11856015_onlyBAV_groupedBF CASCADE;

--- this 'select into' has to be run after every update of impedances or utilities. Takes <10min
select	(array_agg(fromzone_name ORDER BY fromzone_name))[1] as fromzone_name, -- make the from_zone an array, then only retain 1st element (sic! [1] not [0])
		(array_agg(tozone_name ORDER BY fromzone_name))[1] as tozone_name, -- make the to_zone an array, then only retain 2nd element (sic! [2] not [1])		
		array_agg(imp_ttime ORDER BY fromzone_name) as imp_ttime,
		array_agg(imp_distance ORDER BY fromzone_name) as imp_distance,
		array_agg(imp_demand ORDER BY fromzone_name) as imp_demand,
		array_agg(imp_tot_scen1_common ORDER BY fromzone_name) as imp_tot_scen1_common,
		array_agg(imp_tot_scen2_society ORDER BY fromzone_name) as imp_tot_scen2_society,
		array_agg(imp_tot_scen3_technology ORDER BY fromzone_name) as imp_tot_scen3_technology,
		array_agg(imp_tot_scen4_operator ORDER BY fromzone_name) as imp_tot_scen4_operator,
		array_agg(imp_tot_scen5_societyTec ORDER BY fromzone_name) as imp_tot_scen5_societyTec,
		max(u_ample_scen1_common) as u_ample_scen1_common,
		max(u_ample_scen2_society) as u_ample_scen2_society,
		max(u_ample_scen3_technology) as u_ample_scen3_technology,
		max(u_ample_scen4_operator) as u_ample_scen4_operator,
		max(u_ample_scen5_societyTec) as u_ample_scen5_societyTec,
		array_agg(ttime_put ORDER BY fromzone_name) as ttime_put,
		array_agg(ttime_prt ORDER BY fromzone_name) as ttime_prt,
		array_agg(ttime_ratio ORDER BY fromzone_name) as ttime_ratio,
		array_agg(directdist ORDER BY fromzone_name) as directdist,
		array_agg(demand_all_person_purged ORDER BY fromzone_name) as demand_all_person_purged,
		array_agg(demand_put ORDER BY fromzone_name) as demand_put,
		array_agg(sum_ttime_put ORDER BY fromzone_name) as sum_ttime_put,
		array_agg(sum_ttime_put_with_uam ORDER BY fromzone_name) as sum_ttime_put_with_uam,
		sum(sum_ttime_put) as sum_ttime_put_combined,
		sum(sum_ttime_put_with_uam) as sum_ttime_put_with_uam_combined,	
		ST_GeometryN(ST_Collect(geom_point_fromod ORDER BY fromzone_name), 1) as geom_point_fromod, -- make the from_zone_point (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0]); for plotting only; no need to sort the array; attention for from_zone_name == from_zone_geom
		ST_GeometryN(ST_Collect(geom_point_tood ORDER BY fromzone_name), 1) as geom_point_tood, -- make the to_zone_point (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0]); for plotting only; no need to sort the array; attention for from_zone_name == from_zone_geom
		ST_GeometryN(ST_Collect(odconnect), 1) as odconnect -- make the line (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0]); for plotting only; no need to sort the array
INTO TABLE public.odpair_LVM2035_11856015_onlyBAV_groupedBF --BF: 'Back and Forth'
	FROM public.odpair_LVM2035_23712030_onlyBAV_restored
	group by od_concat;



-- 1111111111111111111111111111111111111111111111111111111
-- Scenario 1: Common scenario (equal weighting)
-- 1111111111111111111111111111111111111111111111111111111
DROP SCHEMA IF EXISTS public4qgis_scen1 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen1;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p1_common_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p2_common_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p3_common_top10000
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(9999.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


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

select fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p4_common_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(0.95) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 2222222222222222222222222222222222222222222222222222222
-- Scenario 2: Society scenario (weighting on travel time)
-- 2222222222222222222222222222222222222222222222222222222
DROP SCHEMA IF EXISTS public4qgis_scen2 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen2;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p1_society_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p2_society_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p4_society_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(0.95) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 3333333333333333333333333333333333333333333333333333333
-- Scenario 3: Technology scenario (weighting on distance)
-- 3333333333333333333333333333333333333333333333333333333
DROP SCHEMA IF EXISTS public4qgis_scen3 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen3;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p1_technology_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p2_technology_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p4_technology_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(0.95) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 444444444444444444444444444444444444444444444444444
-- Scenario 4: Operator scenario (weighting on demand)
-- 444444444444444444444444444444444444444444444444444
DROP SCHEMA IF EXISTS public4qgis_scen4 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen4;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p1_operator_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p2_operator_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p4_operator_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(0.95) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 555555555555555555555555555555555555555555555555555
-- Scenario 5: SocietyTec scenario ()
-- 555555555555555555555555555555555555555555555555555
DROP SCHEMA IF EXISTS public4qgis_scen5 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen5;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p1_societytec_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p2_societytec_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, sum_ttime_put, sum_ttime_put_with_uam, sum_ttime_put_combined, sum_ttime_put_with_uam_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p4_societytec_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(0.95) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

