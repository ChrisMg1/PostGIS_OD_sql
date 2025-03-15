--- make subtable subtables for QGIS visualization; (Q)GIS operations are faster when not working with whole database (only 'public4qgis_...')
-- calculate top percentiles, including top 10 with formula

--- this 'select into' has to be run after every update of impedances or utilities AND preceding update of 'odpair_LVM2035_11856015_onlyBAV_groupedBF'
-- takes only 6 minutes ca. 

-- 1111111111111111111111111111111111111111111111111111111
-- Scenario 1: Common scenario (equal weighting)
-- 1111111111111111111111111111111111111111111111111111111
DROP SCHEMA IF EXISTS public4qgis_scen1 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen1;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p1_common_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p2_common_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen1_common, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p4_common_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(0.95) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 2222222222222222222222222222222222222222222222222222222
-- Scenario 2: Society scenario (weighting on travel time)
-- 2222222222222222222222222222222222222222222222222222222
DROP SCHEMA IF EXISTS public4qgis_scen2 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen2;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p1_society_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p2_society_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen2_society, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p4_society_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(0.95) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 3333333333333333333333333333333333333333333333333333333
-- Scenario 3: Technology scenario (weighting on distance)
-- 3333333333333333333333333333333333333333333333333333333
DROP SCHEMA IF EXISTS public4qgis_scen3 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen3;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p1_technology_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p2_technology_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen3_technology, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p4_technology_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(0.95) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 444444444444444444444444444444444444444444444444444
-- Scenario 4: Operator scenario (weighting on demand)
-- 444444444444444444444444444444444444444444444444444
DROP SCHEMA IF EXISTS public4qgis_scen4 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen4;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p1_operator_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p2_operator_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen4_operator, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p4_operator_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(0.95) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 555555555555555555555555555555555555555555555555555
-- Scenario 5: SocietyTec scenario ()
-- 555555555555555555555555555555555555555555555555555
DROP SCHEMA IF EXISTS public4qgis_scen5 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen5;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p1_societytec_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p2_societytec_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen5_societytec, imp_ttime, imp_distance, imp_demand, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p4_societytec_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(0.95) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

