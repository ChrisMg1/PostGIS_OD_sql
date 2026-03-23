-- todo: summe der weights und schauen, was das minimum ist; es sind m. E. immer nur 2 auf einmal "0"

-- Script Part 2 (takes approx. 11.5 h or 4.5 h)

--- This script does the following
---- 1) it takes the intermediate impedances from the preceding script
---- 2) it calculates the total impedance for each scenario. Each scenario has a different stakeholder vector. 
---- 3) it allies the utility function to calculate the utility. 

--- calculate total impedance according to scenario
--- there is one column for each scenario

DROP FUNCTION IF EXISTS CM_TOTAL_IMPEDANCE;
CREATE OR REPLACE FUNCTION CM_TOTAL_IMPEDANCE(
	w_ttime float8,
	R_ttime float8,
	w_distance float8,
	R_distance float8,
	w_demand float8,
	R_demand float8,
	abs_demand float8,
	thresh_demand float8
	)
   RETURNS float8 AS
$$
BEGIN
	if (abs_demand > thresh_demand) then
        return 1.0;
    else
        return ( ( (w_ttime * R_ttime) + (w_distance * R_distance) + (w_demand * R_demand) ) / (w_ttime + w_distance + w_demand) );
	end if;
	exception when others then 
        raise exception 'CM: Something wrong 2';
END;
$$ language 'plpgsql' STRICT;

DROP FUNCTION IF EXISTS ttime_with_uam;
CREATE OR REPLACE FUNCTION ttime_with_uam(
    distance_in FLOAT8,     -- km
    speed_uam_in FLOAT8,    -- km/h
    ttime_put_in FLOAT8,    -- min
    demand_in FLOAT8,
    demand_uam_threshold_in FLOAT8
)
RETURNS FLOAT8 AS 
$$
BEGIN
return ((distance_in / speed_uam_in) * 60) * LEAST(demand_in, demand_uam_threshold_in) +
    ttime_put_in * GREATEST(demand_in - demand_uam_threshold_in, 0);
END
$$ LANGUAGE 'plpgsql' STRICT;

alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS imp_tot_scen1_common float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS imp_tot_scen2_society float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS imp_tot_scen3_technology float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS imp_tot_scen4_operator float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS imp_tot_scen5_societyTec float8;

update only public.odpair_LVM2035_23712030_onlyBAV_restored set
	imp_tot_scen1_common = 		CM_TOTAL_IMPEDANCE(1.0, imp_ttime, 1.0, imp_distance, 1.0, imp_demand, demand_all_person_purged, 768.0) ,
	imp_tot_scen2_society = 	CM_TOTAL_IMPEDANCE(1.0, imp_ttime, 0.1, imp_distance, 0.5, imp_demand, demand_all_person_purged, 768.0) ,
	imp_tot_scen3_technology = 	CM_TOTAL_IMPEDANCE(0.1, imp_ttime, 1.0, imp_distance, 0.5, imp_demand, demand_all_person_purged, 768.0) ,
	imp_tot_scen4_operator = 	CM_TOTAL_IMPEDANCE(0.5, imp_ttime, 0.1, imp_distance, 1.0, imp_demand, demand_all_person_purged, 768.0) ,
	imp_tot_scen5_societyTec = 	CM_TOTAL_IMPEDANCE(1.0, imp_ttime, 0.5, imp_distance, 0.1, imp_demand, demand_all_person_purged, 768.0) ;
	
--- step from impedance to utility (logit, obviously), ln(4) is parameter for normalizing intended
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen1_common float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen2_society float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen3_technology float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen4_operator float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS u_ample_scen5_societyTec float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS sum_ttime_put float8;
alter table public.odpair_LVM2035_23712030_onlyBAV_restored add column IF NOT EXISTS sum_ttime_put_with_uam float8;

update only public.odpair_LVM2035_23712030_onlyBAV_restored set
	u_ample_scen1_common = 		exp(-ln(4)*imp_tot_scen1_common) ,
	u_ample_scen2_society = 	exp(-ln(4)*imp_tot_scen2_society) ,
	u_ample_scen3_technology = 	exp(-ln(4)*imp_tot_scen3_technology) ,
	u_ample_scen4_operator = 	exp(-ln(4)*imp_tot_scen4_operator) ,
	u_ample_scen5_societyTec = 	exp(-ln(4)*imp_tot_scen5_societyTec) ,
	sum_ttime_put = 			demand_put * ttime_put ,
	sum_ttime_put_with_uam = 	ttime_with_uam(directdist, 300.0, ttime_put, demand_put, 768.0);