--- this script

-- Makes the transfer from impedance to utility of a connection
-- Groups the connections to 'back-and-forth ('BF'), so that not only one way are considered
---- Thereby make the fusions of the values
-- make subtable subtables (i.e. schemas) for QGIS visualization; (Q)GIS operations are faster when not working with whole database (only 'public4qgis_...')
-- calculate top percentiles, including top 10 with formula

-- finally: Export to csv for visualization etc.

--DROP TABLE IF EXISTS public.odpair_LVM2035_11856015_onlyBAV_groupedBF_saveCOPY CASCADE;

--CREATE TABLE public.odpair_LVM2035_11856015_onlyBAV_groupedBF_saveCOPY AS
--SELECT * FROM public.odpair_LVM2035_11856015_onlyBAV_groupedBF;



-- function for evaluating the uam travel time (relevant for final considerations)
DROP FUNCTION IF EXISTS ttime_with_uam;
CREATE OR REPLACE FUNCTION ttime_with_uam(
    distance_in FLOAT8,     -- km
    speed_uam_in FLOAT8,    -- km/h
    ttime_put_in FLOAT8,    -- min
    demand_in FLOAT8,
    demand_uam_threshold_in FLOAT8,
    accegr_in FLOAT8 			-- access, egress, process (min); could e.g. be percentage of ttime_put plus penalty. Latter can be defined as input parameter
)
RETURNS FLOAT8 AS 
$$
BEGIN
return (((distance_in / speed_uam_in) * 60) + (2 * accegr_in)) * LEAST(demand_in, demand_uam_threshold_in) +
    ttime_put_in * GREATEST(demand_in - demand_uam_threshold_in, 0);
END
$$ LANGUAGE 'plpgsql' STRICT;


--- step from impedance to utility (logit, obviously), ln(4) is parameter for normalizing intended
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen1_common float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen2_society float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen3_technology float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen4_operator float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen5_societyTec float8;

alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS total_ttime_put float8;

alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS total_ttime_put_with_uam090_30ae float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS total_ttime_put_with_uam260_30ae float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS total_ttime_put_with_uam320_30ae float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS total_ttime_put_with_uam320_noae float8;

-- make scenarios with UAM speed and access/egress and maybe 'UAM-penalty' due to ascent, descent, processing, etc. 

update only public.odpair_LVM2035_23712030_onlyBAV_restored set
	--u_ample_scen1_common		=	exp(-ln(4)*imp_tot_scen1_common) ,
	--u_ample_scen2_society		= 	exp(-ln(4)*imp_tot_scen2_society) ,
	--u_ample_scen3_technology	= 	exp(-ln(4)*imp_tot_scen3_technology) ,
	--u_ample_scen4_operator		= 	exp(-ln(4)*imp_tot_scen4_operator) ,
	--u_ample_scen5_societyTec	= 	exp(-ln(4)*imp_tot_scen5_societyTec) ,
	total_ttime_put				= 	demand_put * ttime_put ,
	total_ttime_put_with_uam090_30ae = 	ttime_with_uam(directdist, 90.0, ttime_put, demand_put, 768.0, 8.5) ,
	total_ttime_put_with_uam260_30ae =	ttime_with_uam(directdist, 260.0, ttime_put, demand_put, 768.0, 8.5) ,
	total_ttime_put_with_uam320_30ae =	ttime_with_uam(directdist, 320.0, ttime_put, demand_put, 768.0, 8.5) ,
	total_ttime_put_with_uam320_noae =	ttime_with_uam(directdist, 320.0, ttime_put, demand_put, 768.0, 0.0) ;


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
		array_agg(imp_tot_scen5_societytec ORDER BY fromzone_name) as imp_tot_scen5_societytec,
		array_agg(u_ample_scen1_common ORDER BY fromzone_name) as u_ample_scen1_common_arr,
		array_agg(u_ample_scen2_society ORDER BY fromzone_name) as u_ample_scen2_society_arr,
		array_agg(u_ample_scen3_technology ORDER BY fromzone_name) as u_ample_scen3_technology_arr,
		array_agg(u_ample_scen4_operator ORDER BY fromzone_name) as u_ample_scen4_operator_arr,
		array_agg(u_ample_scen5_societytec ORDER BY fromzone_name) as u_ample_scen5_societytec_arr,
		max(u_ample_scen1_common) as u_ample_scen1_common,
		max(u_ample_scen2_society) as u_ample_scen2_society,
		max(u_ample_scen3_technology) as u_ample_scen3_technology,
		max(u_ample_scen4_operator) as u_ample_scen4_operator,
		max(u_ample_scen5_societytec) as u_ample_scen5_societytec,
		array_agg(ttime_put ORDER BY fromzone_name) as ttime_put,
		array_agg(ttime_prt ORDER BY fromzone_name) as ttime_prt,
		array_agg(ttime_ratio ORDER BY fromzone_name) as ttime_ratio,
		array_agg(directdist ORDER BY fromzone_name) as directdist,
		array_agg(demand_all_person_purged ORDER BY fromzone_name) as demand_all_person_purged,
		array_agg(demand_put ORDER BY fromzone_name) as demand_put,
		array_agg(total_ttime_put ORDER BY fromzone_name) as total_ttime_put_arr,
		sum(total_ttime_put) as total_ttime_put_combined,		
		array_agg(total_ttime_put_with_uam090_30ae ORDER BY fromzone_name) as total_ttime_put_with_uam090_arr,
		sum(total_ttime_put_with_uam090_30ae) as total_ttime_put_with_uam090_combined,
		array_agg(total_ttime_put_with_uam260_30ae ORDER BY fromzone_name) as total_ttime_put_with_uam260_arr,
		sum(total_ttime_put_with_uam260_30ae) as total_ttime_put_with_uam260_combined,
		array_agg(total_ttime_put_with_uam320_30ae ORDER BY fromzone_name) as total_ttime_put_with_uam320_arr,
		sum(total_ttime_put_with_uam320_30ae) as total_ttime_put_with_uam320_combined,		
		array_agg(total_ttime_put_with_uam320_noae ORDER BY fromzone_name) as total_ttime_put_with_uam320noae_arr,
		sum(total_ttime_put_with_uam320_noae) as total_ttime_put_with_uam320noae_combined,		
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
select fromzone_name, tozone_name, u_ample_scen1_common, u_ample_scen1_common_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p1_common_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen1_common, u_ample_scen1_common_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p2_common_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen1_common, u_ample_scen1_common_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen1_common, u_ample_scen1_common_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen1_common, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen1.u_scen1p4_common_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen1_common >= (select percentile_disc(0.95) within group (order by u_ample_scen1_common) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 2222222222222222222222222222222222222222222222222222222
-- Scenario 2: Society scenario (weighting on travel time)
-- 2222222222222222222222222222222222222222222222222222222
DROP SCHEMA IF EXISTS public4qgis_scen2 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen2;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, u_ample_scen2_society_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p1_society_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, u_ample_scen2_society_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p2_society_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen2_society, u_ample_scen2_society_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen2_society, u_ample_scen2_society_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen2_society, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen2.u_scen2p4_society_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen2_society >= (select percentile_disc(0.95) within group (order by u_ample_scen2_society) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 3333333333333333333333333333333333333333333333333333333
-- Scenario 3: Technology scenario (weighting on distance)
-- 3333333333333333333333333333333333333333333333333333333
DROP SCHEMA IF EXISTS public4qgis_scen3 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen3;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen3_technology, u_ample_scen3_technology_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p1_technology_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen3_technology, u_ample_scen3_technology_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p2_technology_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen3_technology, u_ample_scen3_technology_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen3_technology, u_ample_scen3_technology_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen3_technology, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen3.u_scen3p4_technology_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen3_technology >= (select percentile_disc(0.95) within group (order by u_ample_scen3_technology) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 444444444444444444444444444444444444444444444444444
-- Scenario 4: Operator scenario (weighting on demand)
-- 444444444444444444444444444444444444444444444444444
DROP SCHEMA IF EXISTS public4qgis_scen4 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen4;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen4_operator, u_ample_scen4_operator_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p1_operator_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen4_operator, u_ample_scen4_operator_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p2_operator_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen4_operator, u_ample_scen4_operator_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen4_operator, u_ample_scen4_operator_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen4_operator, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen4.u_scen4p4_operator_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen4_operator >= (select percentile_disc(0.95) within group (order by u_ample_scen4_operator) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- 555555555555555555555555555555555555555555555555555
-- Scenario 5: SocietyTec scenario ()
-- 555555555555555555555555555555555555555555555555555
DROP SCHEMA IF EXISTS public4qgis_scen5 cascade;
CREATE SCHEMA IF NOT EXISTS public4qgis_scen5;

-- create top 10 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen5_societytec, u_ample_scen5_societytec_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p1_societytec_top10
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 100 in this scenario in separate 'scheme'
select fromzone_name, tozone_name, u_ample_scen5_societytec, u_ample_scen5_societytec_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p2_societytec_top100
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(1.0-(99.0 / 11856015.0)) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);

-- create top 10000 in this scenario in separate 'scheme'
SELECT fromzone_name, tozone_name, u_ample_scen5_societytec, u_ample_scen5_societytec_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
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

select fromzone_name, tozone_name, u_ample_scen5_societytec, u_ample_scen5_societytec_arr, imp_ttime, imp_distance, imp_demand, ttime_ratio, ttime_put, ttime_prt, demand_all_person_purged, demand_put, total_ttime_put_arr, total_ttime_put_combined, total_ttime_put_with_uam090_arr, total_ttime_put_with_uam090_combined, total_ttime_put_with_uam260_arr, total_ttime_put_with_uam260_combined, total_ttime_put_with_uam320_arr, total_ttime_put_with_uam320_combined, total_ttime_put_with_uam320noae_arr, total_ttime_put_with_uam320noae_combined, directdist, imp_tot_scen5_societytec, geom_point_fromod, geom_point_tood, odconnect
INTO TABLE public4qgis_scen5.u_scen5p4_societytec_perc95top
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF
where u_ample_scen5_societytec >= (select percentile_disc(0.95) within group (order by u_ample_scen5_societytec) as temp_percentile from public.odpair_LVM2035_11856015_onlyBAV_groupedBF);


-- make cas export. Therefore unnest the arrays for possibility to separate evaluations. 

COPY (
    SELECT 
    	t.fromzone_name,
    	t.tozone_name,
    	t.u_ample_scen1_common,    	-- scenario specific
    	t.total_ttime_put_combined,
    	t.total_ttime_put_with_uam090_combined,
    	t.total_ttime_put_with_uam260_combined,
    	t.total_ttime_put_with_uam320_combined,
    	t.total_ttime_put_with_uam320noae_combined,
      	best_util.u1 AS best_total_ttime_put_arr,
      	best_util.u2 AS best_total_ttime_put_with_uam090_arr,
		best_util.u3 AS best_total_ttime_put_with_uam260_arr,
		best_util.u4 AS best_total_ttime_put_with_uam320_arr,
		best_util.u5 AS best_total_ttime_put_with_uam320noae_arr,
      	best_util.max_value AS max_u_ample_scen1_common_arr    	-- scenario specific
    FROM public4qgis_scen1.u_scen1p3_common_top10000 t
    CROSS JOIN LATERAL (
      SELECT u1, u2, u3, u4, u5, v AS max_value
      FROM unnest(t.total_ttime_put_arr, t.total_ttime_put_with_uam090_arr, t.total_ttime_put_with_uam260_arr, t.total_ttime_put_with_uam320_arr, t.total_ttime_put_with_uam320noae_arr, t.u_ample_scen1_common_arr) AS x(u1, u2, u3, u4, u5, v)
      ORDER BY v DESC
      LIMIT 1
  ) AS best_util
    ORDER BY t.u_ample_scen1_common desc
    LIMIT 10000) TO 'C:\TUMdissDATA\ttimesPUT_top10000_scen1.csv' DELIMITER ',' CSV HEADER;
      	
COPY (
    SELECT 
    	t.fromzone_name, 
    	t.tozone_name, 
    	t.u_ample_scen2_society,    	-- scenario specific
    	t.total_ttime_put_combined,
    	t.total_ttime_put_with_uam090_combined,
    	t.total_ttime_put_with_uam260_combined,
    	t.total_ttime_put_with_uam320_combined,
    	t.total_ttime_put_with_uam320noae_combined,
      	best_util.u1 AS best_total_ttime_put_arr,
      	best_util.u2 AS best_total_ttime_put_with_uam090_arr,
		best_util.u3 AS best_total_ttime_put_with_uam260_arr,
		best_util.u4 AS best_total_ttime_put_with_uam320_arr,
		best_util.u5 AS best_total_ttime_put_with_uam320noae_arr,
      	best_util.max_value AS max_u_ample_scen2_society_arr    	-- scenario specific
    FROM public4qgis_scen2.u_scen2p3_society_top10000 t
    CROSS JOIN LATERAL (
      SELECT u1, u2, u3, u4, u5, v AS max_value
      FROM unnest(t.total_ttime_put_arr, t.total_ttime_put_with_uam090_arr, t.total_ttime_put_with_uam260_arr, t.total_ttime_put_with_uam320_arr, t.total_ttime_put_with_uam320noae_arr, t.u_ample_scen2_society_arr) AS x(u1, u2, u3, u4, u5, v)
      ORDER BY v DESC
      LIMIT 1
  ) AS best_util
    ORDER BY u_ample_scen2_society desc
    LIMIT 10000) TO 'C:\TUMdissDATA\ttimesPUT_top10000_scen2.csv' DELIMITER ',' CSV HEADER;

COPY (
    SELECT 
    	t.fromzone_name, 
    	t.tozone_name, 
    	t.u_ample_scen3_technology,    	-- scenario specific
    	t.total_ttime_put_combined,
    	t.total_ttime_put_with_uam090_combined,
    	t.total_ttime_put_with_uam260_combined,
    	t.total_ttime_put_with_uam320_combined,
    	t.total_ttime_put_with_uam320noae_combined,
      	best_util.u1 AS best_total_ttime_put_arr,
      	best_util.u2 AS best_total_ttime_put_with_uam090_arr,
		best_util.u3 AS best_total_ttime_put_with_uam260_arr,
		best_util.u4 AS best_total_ttime_put_with_uam320_arr,
		best_util.u5 AS best_total_ttime_put_with_uam320noae_arr,
      	best_util.max_value AS max_u_ample_scen3_technology_arr    	-- scenario specific
    FROM public4qgis_scen3.u_scen3p3_technology_top10000 t
    CROSS JOIN LATERAL (
      SELECT u1, u2, u3, u4, u5, v AS max_value
      FROM unnest(t.total_ttime_put_arr, t.total_ttime_put_with_uam090_arr, t.total_ttime_put_with_uam260_arr, t.total_ttime_put_with_uam320_arr, t.total_ttime_put_with_uam320noae_arr, t.u_ample_scen3_technology_arr) AS x(u1, u2, u3, u4, u5, v)
      ORDER BY v DESC
      LIMIT 1
  ) AS best_util
    ORDER BY u_ample_scen3_technology desc
    LIMIT 10000) TO 'C:\TUMdissDATA\ttimesPUT_top10000_scen3.csv' DELIMITER ',' CSV HEADER;

COPY (
    SELECT 
    	t.fromzone_name, 
    	t.tozone_name, 
    	t.u_ample_scen4_operator,    	-- scenario specific
    	t.total_ttime_put_combined,
    	t.total_ttime_put_with_uam090_combined,
    	t.total_ttime_put_with_uam260_combined,
    	t.total_ttime_put_with_uam320_combined,
    	t.total_ttime_put_with_uam320noae_combined,
      	best_util.u1 AS best_total_ttime_put_arr,
      	best_util.u2 AS best_total_ttime_put_with_uam090_arr,
		best_util.u3 AS best_total_ttime_put_with_uam260_arr,
		best_util.u4 AS best_total_ttime_put_with_uam320_arr,
		best_util.u5 AS best_total_ttime_put_with_uam320noae_arr,
      	best_util.max_value AS max_u_ample_scen4_operator_arr    	-- scenario specific
    FROM public4qgis_scen4.u_scen4p3_operator_top10000 t
    CROSS JOIN LATERAL (
      SELECT u1, u2, u3, u4, u5, v AS max_value
      FROM unnest(t.total_ttime_put_arr, t.total_ttime_put_with_uam090_arr, t.total_ttime_put_with_uam260_arr, t.total_ttime_put_with_uam320_arr, t.total_ttime_put_with_uam320noae_arr, t.u_ample_scen4_operator_arr) AS x(u1, u2, u3, u4, u5, v)
      ORDER BY v DESC
      LIMIT 1
  ) AS best_util
    ORDER BY u_ample_scen4_operator desc
    LIMIT 10000) TO 'C:\TUMdissDATA\ttimesPUT_top10000_scen4.csv' DELIMITER ',' CSV HEADER;
