--- here only querys for bavarian table
--- export: Prepare data in database cm_UAM2035fromSQLite, table odpair_2035_fromsqlite_44342281_raw
--- export to odpair_lvm2035_23716900_onlybav
---- filter: only bav taz's
---- filter: from != to
--- finally transfer to new database xyz

--- this 'select into' has to be run after every update of impedances or utilities. Takes <10min
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
		array_agg(ttime_ratio) as ttime_ratio,
		array_agg(directdist) as directdist,
		array_agg(demand_all_person_purged) as demand_all_person_purged,
		ST_GeometryN(ST_Collect(geom_point_fromod), 1) as geom_point_fromod, -- make the from_zone_point (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0]); attention for from_zone_name == from_zone_geom
		ST_GeometryN(ST_Collect(geom_point_tood), 1) as geom_point_tood, -- make the to_zone_point (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0]); attention for from_zone_name == from_zone_geom
		ST_GeometryN(ST_Collect(odconnect), 1) as odconnect -- make the line (geom) an array ('collection' with geom), then only retain 1st element (sic! [1] not [0])
INTO TABLE public.odpair_LVM2035_11856015_onlyBAV_groupedBF --BF: 'Back and Forth'
	FROM public.odpair_LVM2035_23712030_onlyBAV
	group by od_concat;

select * from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;

CREATE INDEX scen1_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen1_common); -- index on affected utility column
CREATE INDEX scen2_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen2_society); -- index on affected utility column
CREATE INDEX scen3_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen3_technology); -- index on affected utility column
CREATE INDEX scen4_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen4_operator); -- index on affected utility column
CREATE INDEX scen5_index ON public.odpair_LVM2035_11856015_onlyBAV_groupedBF(u_ample_scen5_societyTec); -- index on affected utility column


-- make evaluations for impedances (takes ~1min each); optional LaTeX output
select round(min(imp_tot_scen1_common)::numeric, 4) 		as min_imp_tot_scen1, round(avg(imp_tot_scen1_common)::numeric, 4) 		as avg_imp_tot_scen1, round(max(imp_tot_scen1_common)::numeric, 4) 		as max_imp_tot_scen1 from odpair_LVM2035_23712030_onlyBAV;
select '$', round(min(imp_tot_scen1_common)::numeric, 4), '$ & $' , round(avg(imp_tot_scen1_common)::numeric, 4), '$ & $', round(max(imp_tot_scen1_common)::numeric, 4), '$ \\' from odpair_LVM2035_23712030_onlyBAV;

select round(min(imp_tot_scen2_society)::numeric, 4) 		as min_imp_tot_scen2, round(avg(imp_tot_scen2_society)::numeric, 4) 	as avg_imp_tot_scen2, round(max(imp_tot_scen2_society)::numeric, 4) 	as max_imp_tot_scen2 from odpair_LVM2035_23712030_onlyBAV;
select '$', round(min(imp_tot_scen2_society)::numeric, 4), '$ & $' , round(avg(imp_tot_scen2_society)::numeric, 4), '$ & $', round(max(imp_tot_scen2_society)::numeric, 4), '$ \\' from odpair_LVM2035_23712030_onlyBAV;

select round(min(imp_tot_scen3_technology)::numeric, 4) 	as min_imp_tot_scen3, round(avg(imp_tot_scen3_technology)::numeric, 4) 	as avg_imp_tot_scen3, round(max(imp_tot_scen3_technology)::numeric, 4) 	as max_imp_tot_scen3 from odpair_LVM2035_23712030_onlyBAV;
select '$', round(min(imp_tot_scen3_technology)::numeric, 4), '$ & $' , round(avg(imp_tot_scen3_technology)::numeric, 4), '$ & $', round(max(imp_tot_scen3_technology)::numeric, 4), '$ \\' from odpair_LVM2035_23712030_onlyBAV;

select round(min(imp_tot_scen4_operator)::numeric, 4) 		as min_imp_tot_scen4, round(avg(imp_tot_scen4_operator)::numeric, 4) 	as avg_imp_tot_scen4, round(max(imp_tot_scen4_operator)::numeric, 4) 	as max_imp_tot_scen4 from odpair_LVM2035_23712030_onlyBAV;
select '$', round(min(imp_tot_scen4_operator)::numeric, 4), '$ & $' , round(avg(imp_tot_scen4_operator)::numeric, 4), '$ & $', round(max(imp_tot_scen4_operator)::numeric, 4), '$ \\' from odpair_LVM2035_23712030_onlyBAV;

select round(min(imp_tot_scen5_societyTec)::numeric, 4) 	as min_imp_tot_scen5, round(avg(imp_tot_scen5_societyTec)::numeric, 4) 	as avg_imp_tot_scen5, round(max(imp_tot_scen5_societyTec)::numeric, 4) 	as max_imp_tot_scen5 from odpair_LVM2035_23712030_onlyBAV;
select '$', round(min(imp_tot_scen5_societyTec)::numeric, 4), '$ & $' , round(avg(imp_tot_scen5_societyTec)::numeric, 4), '$ & $', round(max(imp_tot_scen5_societyTec)::numeric, 4), '$ \\' from odpair_LVM2035_23712030_onlyBAV;


-- make evaluations for utilities (takes some seconds each); optional LaTeX output
select round(min(u_ample_scen1_common)::numeric, 4) 		as min_utility_scen1, round(avg(u_ample_scen1_common)::numeric, 4) 		as avg_utility_scen1, round(max(u_ample_scen1_common)::numeric, 4) 		as max_utility_scen1 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select '$', round(min(u_ample_scen1_common)::numeric, 4), '$ & $' , round(avg(u_ample_scen1_common)::numeric, 4), '$ & $', round(max(u_ample_scen1_common)::numeric, 4), '$ \\' from odpair_LVM2035_11856015_onlyBAV_groupedBF;

select round(min(u_ample_scen2_society)::numeric, 4) 		as min_utility_scen2, round(avg(u_ample_scen2_society)::numeric, 4) 	as avg_utility_scen2, round(max(u_ample_scen2_society)::numeric, 4) 	as max_utility_scen2 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select '$', round(min(u_ample_scen2_society)::numeric, 4), '$ & $' , round(avg(u_ample_scen2_society)::numeric, 4), '$ & $', round(max(u_ample_scen2_society)::numeric, 4), '$ \\' from odpair_LVM2035_11856015_onlyBAV_groupedBF;

select round(min(u_ample_scen3_technology)::numeric, 4) 	as min_utility_scen3, round(avg(u_ample_scen3_technology)::numeric, 4) 	as avg_utility_scen3, round(max(u_ample_scen3_technology)::numeric, 4) 	as max_utility_scen3 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select '$', round(min(u_ample_scen3_technology)::numeric, 4), '$ & $' , round(avg(u_ample_scen3_technology)::numeric, 4), '$ & $', round(max(u_ample_scen3_technology)::numeric, 4), '$ \\' from odpair_LVM2035_11856015_onlyBAV_groupedBF;

select round(min(u_ample_scen4_operator)::numeric, 4) 		as min_utility_scen4, round(avg(u_ample_scen4_operator)::numeric, 4) 	as avg_utility_scen4, round(max(u_ample_scen4_operator)::numeric, 4) 	as max_utility_scen4 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select '$', round(min(u_ample_scen4_operator)::numeric, 4), '$ & $' , round(avg(u_ample_scen4_operator)::numeric, 4), '$ & $', round(max(u_ample_scen4_operator)::numeric, 4), '$ \\' from odpair_LVM2035_11856015_onlyBAV_groupedBF;

select round(min(u_ample_scen5_societyTec)::numeric, 4) 	as min_utility_scen5, round(avg(u_ample_scen5_societyTec)::numeric, 4)	as avg_utility_scen5, round(max(u_ample_scen5_societyTec)::numeric, 4)	as max_utility_scen5 from odpair_LVM2035_11856015_onlyBAV_groupedBF;
select '$', round(min(u_ample_scen5_societyTec)::numeric, 4), '$ & $' , round(avg(u_ample_scen5_societyTec)::numeric, 4), '$ & $', round(max(u_ample_scen5_societyTec)::numeric, 4), '$ \\' from odpair_LVM2035_11856015_onlyBAV_groupedBF;


--- quantiles for each scenario to copy to LaTeX
---- all qantiles and avg/std for scenario 1 (!! Only select, NO 'into...')
select  
  '$ ' || round((percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common))::numeric, 4) || ' $ & ' as scen1_top10, --attention: GroupedBF = 1/2 "onlyBav"
  '$ ' || round((percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common))::numeric, 4) || ' $ & ' as scen1_95perc_top5perc,
  '$ ' || round((percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common))::numeric, 4) || ' $ & ' as scen1_75perc_top25perc,
  '$ ' || round((percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common))::numeric, 4) || ' $ & ' as scen1_50perc_top50perc,
  '$ ' || round((percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen1_common))::numeric, 4) || ' $ \\' as scen1_25perc_top75perc
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select round(avg(u_ample_scen1_common)::numeric, 4) as scen1_avg, round(stddev(u_ample_scen1_common)::numeric, 4) as scen1_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 2 (!! Only select, NO 'into...')
select  
  '$ ' || round((percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society))::numeric, 4) || ' $ & ' as scen2_top10, --attention: GroupedBF = 1/2 "onlyBav"
  '$ ' || round((percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society))::numeric, 4) || ' $ & ' as scen2_95perc_top5perc,
  '$ ' || round((percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society))::numeric, 4) || ' $ & ' as scen2_75perc_top25perc,
  '$ ' || round((percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society))::numeric, 4) || ' $ & ' as scen2_50perc_top50perc,
  '$ ' || round((percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen2_society))::numeric, 4) || ' $ \\' as scen2_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select round(avg(u_ample_scen2_society)::numeric, 4) as scen2_avg, round(stddev(u_ample_scen2_society)::numeric, 4) as scen2_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 3 (!! Only select, NO 'into...')
select  
  '$ ' || round((percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology))::numeric, 4) || ' $ & ' as scen3_top10, --attention: GroupedBF = 1/2 "onlyBav"
  '$ ' || round((percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology))::numeric, 4) || ' $ & ' as scen3_95perc_top5perc,
  '$ ' || round((percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology))::numeric, 4) || ' $ & ' as scen3_75perc_top25perc,
  '$ ' || round((percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology))::numeric, 4) || ' $ & ' as scen3_50perc_top50perc,
  '$ ' || round((percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen3_technology))::numeric, 4) || ' $ \\' as scen3_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select round(avg(u_ample_scen3_technology)::numeric, 4) as scen3_avg, round(stddev(u_ample_scen3_technology)::numeric, 4) as scen3_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 4 (!! Only select, NO 'into...')
select  
  '$ ' || round((percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator))::numeric, 4) || ' $ & ' as scen4_top10, --attention: GroupedBF = 1/2 "onlyBav"
  '$ ' || round((percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator))::numeric, 4) || ' $ & ' as scen4_95perc_top5perc,
  '$ ' || round((percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator))::numeric, 4) || ' $ & ' as scen4_75perc_top25perc,
  '$ ' || round((percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator))::numeric, 4) || ' $ & ' as scen4_50perc_top50perc,
  '$ ' || round((percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen4_operator))::numeric, 4) || ' $ \\' as scen4_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select round(avg(u_ample_scen4_operator)::numeric, 4) as scen4_avg, round(stddev(u_ample_scen4_operator)::numeric, 4) as scen4_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;

---- all qantiles and avg/std for scenario 5 (!! Only select, NO 'into...')
select  
  '$ ' || round((percentile_disc(1.0-(9.0 / 11856015.0)) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec))::numeric, 4) || ' $ & ' as scen5_top10, --attention: GroupedBF = 1/2 "onlyBav"
  '$ ' || round((percentile_disc(0.95) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec))::numeric, 4) || ' $ & ' as scen5_95perc_top5perc,
  '$ ' || round((percentile_disc(0.75) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec))::numeric, 4) || ' $ & ' as scen5_75perc_top25perc,
  '$ ' || round((percentile_disc(0.50) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec))::numeric, 4) || ' $ & ' as scen5_50perc_top50perc,
  '$ ' || round((percentile_disc(0.25) within group (order by odpair_LVM2035_11856015_onlyBAV_groupedBF.u_ample_scen5_societyTec))::numeric, 4) || ' $ \\' as scen5_25perc_top75perc  
from public.odpair_LVM2035_11856015_onlyBAV_groupedBF;
select round(avg(u_ample_scen5_societyTec)::numeric, 4) as scen5_avg, round(stddev(u_ample_scen5_societyTec)::numeric, 4) as scen5_stddev from odpair_LVM2035_11856015_onlyBAV_groupedBF;



-- LaTeX-parsed selects _IMPEDANCES_ for top connections: 
select '$', row_number() over(order by u_ample_scen1_common desc),		'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen1_common::numeric, 4), 		'$ & \makecell{$', round(imp_ttime[1]::numeric, 4), '$ \\ $', round(imp_ttime[2]::numeric, 4), '$} & \makecell{$', round(imp_distance[1]::numeric, 4), '$ \\ $', round(imp_distance[2]::numeric, 4), '$} & \makecell{$', round(imp_demand[1]::numeric, 4), '$ \\ $', round(imp_demand[2]::numeric, 4), '$} & $', round(directdist[1]::numeric, 4), '$ \\' from public4qgis_scen1.u_scen1p1_common_top10 	order by u_ample_scen1_common desc;
select '$', row_number() over(order by u_ample_scen2_society desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen2_society::numeric, 4), 		'$ & \makecell{$', round(imp_ttime[1]::numeric, 4), '$ \\ $', round(imp_ttime[2]::numeric, 4), '$} & \makecell{$', round(imp_distance[1]::numeric, 4), '$ \\ $', round(imp_distance[2]::numeric, 4), '$} & \makecell{$', round(imp_demand[1]::numeric, 4), '$ \\ $', round(imp_demand[2]::numeric, 4), '$} & $', round(directdist[1]::numeric, 4), '$ \\' from public4qgis_scen2.u_scen2p1_society_top10 	order by u_ample_scen2_society desc;
select '$', row_number() over(order by u_ample_scen3_technology desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen3_technology::numeric, 4), 	'$ & \makecell{$', round(imp_ttime[1]::numeric, 4), '$ \\ $', round(imp_ttime[2]::numeric, 4), '$} & \makecell{$', round(imp_distance[1]::numeric, 4), '$ \\ $', round(imp_distance[2]::numeric, 4), '$} & \makecell{$', round(imp_demand[1]::numeric, 4), '$ \\ $', round(imp_demand[2]::numeric, 4), '$} & $', round(directdist[1]::numeric, 4), '$ \\' from public4qgis_scen3.u_scen3p1_technology_top10 order by u_ample_scen3_technology desc;
select '$', row_number() over(order by u_ample_scen4_operator desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen4_operator::numeric, 4), 		'$ & \makecell{$', round(imp_ttime[1]::numeric, 4), '$ \\ $', round(imp_ttime[2]::numeric, 4), '$} & \makecell{$', round(imp_distance[1]::numeric, 4), '$ \\ $', round(imp_distance[2]::numeric, 4), '$} & \makecell{$', round(imp_demand[1]::numeric, 4), '$ \\ $', round(imp_demand[2]::numeric, 4), '$} & $', round(directdist[1]::numeric, 4), '$ \\' from public4qgis_scen4.u_scen4p1_operator_top10 	order by u_ample_scen4_operator desc;
select '$', row_number() over(order by u_ample_scen5_societytec desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen5_societytec::numeric, 4), 	'$ & \makecell{$', round(imp_ttime[1]::numeric, 4), '$ \\ $', round(imp_ttime[2]::numeric, 4), '$} & \makecell{$', round(imp_distance[1]::numeric, 4), '$ \\ $', round(imp_distance[2]::numeric, 4), '$} & \makecell{$', round(imp_demand[1]::numeric, 4), '$ \\ $', round(imp_demand[2]::numeric, 4), '$} & $', round(directdist[1]::numeric, 4), '$ \\' from public4qgis_scen5.u_scen5p1_societytec_top10 order by u_ample_scen5_societytec desc;

-- LaTeX-parsed selects _ABS-VALUES_ for top connections: 
select '$', row_number() over(order by u_ample_scen1_common desc),		'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen1_common::numeric, 4), 		'$ & \makecell{$', round(ttime_ratio[1]::numeric, 4), '$ \\ $', round(ttime_ratio[2]::numeric, 4), '$} & $', round(directdist[2]::numeric, 4), '$ & \makecell{$', round(demand_all_person_purged[1]::numeric, 4), '$ \\ $', round(demand_all_person_purged[2]::numeric, 4), '$} \\' from public4qgis_scen1.u_scen1p1_common_top10 	order by u_ample_scen1_common desc;
select '$', row_number() over(order by u_ample_scen2_society desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen2_society::numeric, 4), 		'$ & \makecell{$', round(ttime_ratio[1]::numeric, 4), '$ \\ $', round(ttime_ratio[2]::numeric, 4), '$} & $', round(directdist[2]::numeric, 4), '$ & \makecell{$', round(demand_all_person_purged[1]::numeric, 4), '$ \\ $', round(demand_all_person_purged[2]::numeric, 4), '$} \\' from public4qgis_scen2.u_scen2p1_society_top10 	order by u_ample_scen2_society desc;
select '$', row_number() over(order by u_ample_scen3_technology desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen3_technology::numeric, 4), 	'$ & \makecell{$', round(ttime_ratio[1]::numeric, 4), '$ \\ $', round(ttime_ratio[2]::numeric, 4), '$} & $', round(directdist[2]::numeric, 4), '$ & \makecell{$', round(demand_all_person_purged[1]::numeric, 4), '$ \\ $', round(demand_all_person_purged[2]::numeric, 4), '$} \\' from public4qgis_scen3.u_scen3p1_technology_top10 order by u_ample_scen3_technology desc;
select '$', row_number() over(order by u_ample_scen4_operator desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen4_operator::numeric, 4), 		'$ & \makecell{$', round(ttime_ratio[1]::numeric, 4), '$ \\ $', round(ttime_ratio[2]::numeric, 4), '$} & $', round(directdist[2]::numeric, 4), '$ & \makecell{$', round(demand_all_person_purged[1]::numeric, 4), '$ \\ $', round(demand_all_person_purged[2]::numeric, 4), '$} \\' from public4qgis_scen4.u_scen4p1_operator_top10 	order by u_ample_scen4_operator desc;
select '$', row_number() over(order by u_ample_scen5_societytec desc), 	'$ &', fromzone_name, '--', tozone_name, '& $', round(u_ample_scen5_societytec::numeric, 4), 	'$ & \makecell{$', round(ttime_ratio[1]::numeric, 4), '$ \\ $', round(ttime_ratio[2]::numeric, 4), '$} & $', round(directdist[2]::numeric, 4), '$ & \makecell{$', round(demand_all_person_purged[1]::numeric, 4), '$ \\ $', round(demand_all_person_purged[2]::numeric, 4), '$} \\' from public4qgis_scen5.u_scen5p1_societytec_top10 order by u_ample_scen5_societytec desc;

-- Select top connections as SQL
select * from public4qgis_scen1.u_scen1p1_common_top10 		order by u_ample_scen1_common desc;
select * from public4qgis_scen2.u_scen2p1_society_top10 	order by u_ample_scen2_society desc;
select * from public4qgis_scen3.u_scen3p1_technology_top10 	order by u_ample_scen3_technology desc;
select * from public4qgis_scen4.u_scen4p1_operator_top10 	order by u_ample_scen4_operator desc;
select * from public4qgis_scen5.u_scen5p1_societytec_top10 	order by u_ample_scen5_societytec desc;