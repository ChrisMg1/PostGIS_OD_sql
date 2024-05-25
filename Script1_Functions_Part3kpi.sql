--- Add columns for various KPIs of the resulting network
-- create a column with passengers x travel time for each row traditional transport (filter for high metric values afterwards)
alter table lvm_od_onlybav add column IF NOT EXISTS PAX_h_BASE float;
-- ...and UAM
alter table lvm_od_onlybav add column IF NOT EXISTS PAX_h_UAM_all float;
update only lvm_od_onlybav set
	PAX_h_BASE = ( ((demand_pkw + demand_pkwm) * ttime_prt) + (demand_put * ttime_put) ) / 60,
	PAX_h_UAM_all = (demand_ivoev * ttime_uam_min) / 60;

-- column for PAX with capacity limit of UAM 4 PAX/flight, 4 flight per hour
alter table lvm_od_onlybav add column IF NOT EXISTS PAX_h_UAM_capa float;
update only lvm_od_onlybav set PAX_h_UAM_capa = 
	(greatest( ((demand_pkw + demand_pkwm) - (4*24*4) ), 0) * ttime_prt) + -- reduce prt_demand by UAM_demand and assure that demand not negative
	(greatest( (demand_pkw + demand_pkwm), (4*24*4) ) * ttime_uam) + -- assume that they are using UAM and assure that its not greater than the overall demand
	(demand_put * ttime_put) ) 
	/ 60;	-- and blah2

	
	
--- TODO: From split to KPI (PAXh)
alter table lvm_od_onlybav add column IF NOT EXISTS PAX_h_UAM_test float;
update only lvm_od_onlybav set PAX_h_UAM_test = 
	(demand_pkw + demand_pkwm) -	
	greatest( ((demand_pkw + demand_pkwm) - (4*24*4) ), 0) - -- reduce prt_demand by UAM_demand and assure that demand not negative
	least( (demand_pkw + demand_pkwm), (4*24*4) ) + 1;	-- and blah2


