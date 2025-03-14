--- here only querys for bavarian table
--- export: Prepare data in database cm_UAM2035fromSQLite, table odpair_2035_fromsqlite_44342281_raw
--- export to odpair_lvm2035_23716900_onlybav
---- filter: only bav taz's
---- filter: from != to
--- finally transfer to new database xyz


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


-- make evaluations for impedances
select min(imp_tot_scen1_common) 		as min_imp_tot_scen1, avg(imp_tot_scen1_common) 	as avg_imp_tot_scen1, max(imp_tot_scen1_common) 	as max_imp_tot_scen1 from odpair_LVM2035_23712030_onlyBAV;
select min(imp_tot_scen2_society) 		as min_imp_tot_scen2, avg(imp_tot_scen2_society) 	as avg_imp_tot_scen2, max(imp_tot_scen2_society) 	as max_imp_tot_scen2 from odpair_LVM2035_23712030_onlyBAV;
select min(imp_tot_scen3_technology) 	as min_imp_tot_scen3, avg(imp_tot_scen3_technology) as avg_imp_tot_scen3, max(imp_tot_scen3_technology) as max_imp_tot_scen3 from odpair_LVM2035_23712030_onlyBAV;
select min(imp_tot_scen4_operator) 		as min_imp_tot_scen4, avg(imp_tot_scen4_operator) 	as avg_imp_tot_scen4, max(imp_tot_scen4_operator) 	as max_imp_tot_scen4 from odpair_LVM2035_23712030_onlyBAV;
select min(imp_tot_scen5_societyTec) 	as min_imp_tot_scen5, avg(imp_tot_scen5_societyTec) as avg_imp_tot_scen5, max(imp_tot_scen5_societyTec) as max_imp_tot_scen5 from odpair_LVM2035_23712030_onlyBAV;

-- make evaluations for utilities
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







