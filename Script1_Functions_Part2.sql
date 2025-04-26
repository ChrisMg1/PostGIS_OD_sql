-- todo: summe der weights und schauen, was das minimum ist; es sind m. E. immer nur 2 auf einmal "0"

-- Script Part 2 (takes approx. 11 h)

--- This script does the following
---- 1) it takes the intermediate impedances from the preceding script
---- 2) it calculates the total impedance for each scenario. Each scenario has a different stakeholder vector. 
---- 3) it allies the utility function to calculate the utility. 

--- calculate total impedance according to scenario
--- there is one column for each scenario
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen1_common float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen2_society float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen3_technology float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen4_operator float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen5_societyTec float8;

update only public.odpair_LVM2035_23712030_onlyBAV set 
	imp_tot_scen1_common = 		( (1.0 * imp_ttime) + (1.0 * imp_distance) + (1.0 * imp_demand) ) / (1.0 + 1.0 + 1.0) ,
	imp_tot_scen2_society = 	( (1.0 * imp_ttime) + (0.1 * imp_distance) + (0.5 * imp_demand) ) / (1.0 + 0.1 + 0.5) ,
	imp_tot_scen3_technology = 	( (0.1 * imp_ttime) + (1.0 * imp_distance) + (0.5 * imp_demand) ) / (0.1 + 1.0 + 0.5) ,
	imp_tot_scen4_operator = 	( (0.5 * imp_ttime) + (0.1 * imp_distance) + (1.0 * imp_demand) ) / (0.5 + 0.1 + 1.0) ,
	imp_tot_scen5_societyTec = 	( (1.0 * imp_ttime) + (0.5 * imp_distance) + (0.1 * imp_demand) ) / (1.0 + 0.5 + 0.1) ;

--- step from impedance to utility (logit, obviously), ln(4) is parameter for normalizing intended
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen1_common float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen2_society float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen3_technology float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen4_operator float8;
alter table public.odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen5_societyTec float8;

update only public.odpair_LVM2035_23712030_onlyBAV set
	u_ample_scen1_common = 		exp(-ln(4)*imp_tot_scen1_common) ,
	u_ample_scen2_society = 	exp(-ln(4)*imp_tot_scen2_society) ,
	u_ample_scen3_technology = 	exp(-ln(4)*imp_tot_scen3_technology) ,
	u_ample_scen4_operator = 	exp(-ln(4)*imp_tot_scen4_operator) ,
	u_ample_scen5_societyTec = 	exp(-ln(4)*imp_tot_scen5_societyTec) ;

