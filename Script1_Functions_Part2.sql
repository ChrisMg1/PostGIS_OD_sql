-- todo: summe der weights und schauen, was das minimum ist; es sind m. E. immer nur 2 auf einmal "0"

--- calculate impedance according to scenario
--- there is one column for each scenario
alter table lvm_od_onlybav add column IF NOT EXISTS total_impedance_scen1 float;
alter table lvm_od_onlybav add column IF NOT EXISTS total_impedance_scen2 float;
alter table lvm_od_onlybav add column IF NOT EXISTS total_impedance_scen3 float;

update only lvm_od_onlybav set 
	total_impedance_scen1 = ( (1 * ttime_weight) + (1 * distance_weight) + (1 * demand_weight) ) / (1 + 1 + 1) ,
	total_impedance_scen2 = ( (1 * ttime_weight) + (0.1 * distance_weight) + (0.1 * demand_weight) ) / (1 + 0.1 + 0.1) ,
	total_impedance_scen3 = ( (0.1 * ttime_weight) + (0.1 * distance_weight) + (1 * demand_weight) ) / (0.1 + 0.1 + 1) ;


--- step from impedance to utility (logit, obviously), ln(4) ist for normalizing intended
alter table lvm_od_onlybav add column IF NOT EXISTS cm_metric_scen1 float;
alter table lvm_od_onlybav add column IF NOT EXISTS cm_metric_scen2 float;
alter table lvm_od_onlybav add column IF NOT EXISTS cm_metric_scen3 float;

update only lvm_od_onlybav set 
	cm_metric_scen1 = exp(-ln(4)*total_impedance_scen1) ,
	cm_metric_scen2 = exp(-ln(4)*total_impedance_scen2) ,
	cm_metric_scen3 = exp(-ln(4)*total_impedance_scen3) ;
