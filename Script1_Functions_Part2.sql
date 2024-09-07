-- todo: summe der weights und schauen, was das minimum ist; es sind m. E. immer nur 2 auf einmal "0"

--- calculate total impedance according to scenario
--- there is one column for each scenario
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen1_common float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen2_society float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen3_technology float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_tot_scen4_operator float;

update only odpair_LVM2035_23712030_onlyBAV set 
	imp_tot_scen1_common = ( (1.0 * imp_ttime) + (1.0 * imp_distance) + (1.0 * imp_demand) ) / (1.0 + 1.0 + 1.0) ,
	imp_tot_scen2_society = ( (1.0 * imp_ttime) + (0.1 * imp_distance) + (0.5 * imp_demand) ) / (1.0 + 0.1 + 0.5) ,
	imp_tot_scen3_technology = ( (0.1 * imp_ttime) + (1.0 * imp_distance) + (0.5 * imp_demand) ) / (0.1 + 1.0 + 0.5) ,
	imp_tot_scen4_operator = ( (0.5 * imp_ttime) + (0.1 * imp_distance) + (1.0 * imp_demand) ) / (0.5 + 0.1 + 1.0) ;

select min(imp_tot_scen1_common) as min_imp_tot_scen1, avg(imp_tot_scen1_common) as avg_imp_tot_scen1, max(imp_tot_scen1_common) as max_imp_tot_scen1 from odpair_LVM2035_23712030_onlyBAV;
select min(imp_tot_scen2_society) as min_imp_tot_scen2, avg(imp_tot_scen2_society) as avg_imp_tot_scen2, max(imp_tot_scen2_society) as max_imp_tot_scen2 from odpair_LVM2035_23712030_onlyBAV;
select min(imp_tot_scen3_technology) as min_imp_tot_scen3, avg(imp_tot_scen3_technology) as avg_imp_tot_scen3, max(imp_tot_scen3_technology) as max_imp_tot_scen3 from odpair_LVM2035_23712030_onlyBAV;
select min(imp_tot_scen4_operator) as min_imp_tot_scen4, avg(imp_tot_scen4_operator) as avg_imp_tot_scen4, max(imp_tot_scen4_operator) as max_imp_tot_scen4 from odpair_LVM2035_23712030_onlyBAV;

--- step from impedance to utility (logit, obviously), ln(4) is parameter for normalizing intended
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen1_common float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen2_society float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen3_technology float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS u_ample_scen4_operator float;

update only odpair_LVM2035_23712030_onlyBAV set 
	u_ample_scen1_common = exp(-ln(4)*imp_tot_scen1_common) ,
	u_ample_scen2_society = exp(-ln(4)*imp_tot_scen2_society) ,
	u_ample_scen3_technology = exp(-ln(4)*imp_tot_scen3_technology) ,
	u_ample_scen4_operator = exp(-ln(4)*imp_tot_scen4_operator) ;