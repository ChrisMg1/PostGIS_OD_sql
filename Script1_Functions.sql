-- recoding of the weight functions (travel impedance) from python scripts. 
-- Goal: Continuous Metric for OD-connections

-- RUN whole script (not line by line)

CREATE OR REPLACE FUNCTION random_between(low INT ,high INT)
   RETURNS INT AS
$$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$ language 'plpgsql' STRICT;

CREATE OR REPLACE FUNCTION TTIME_LOGIT_WEIGHT(TTR float)
   RETURNS float AS
$$
DECLARE p_w float :=2.5;
DECLARE a2_w float:=3.0;

BEGIN
   if TTR < 100.0 then
		RETURN (1 / (1 + exp(a2_w * (TTR - p_W)) ));
	else
		return 0.0;  -- function would be out-of-range-error
	end if;
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION DEMAND_MAX_ADAPT_WEIGHT(imp float)
   RETURNS float AS
$$
-- Calibration factors to make things suitable for transport modelling
DECLARE d_m float:=1.7034;
DECLARE w_m float:=0.35;
DECLARE s_m float:=0.0;
imp_in float=(w_m*(imp - s_m));
begin
	if imp < 100.0 then
		RETURN (1 - d_m*( sqrt(2/pi())*imp_in*imp_in*exp(-imp_in*imp_in/2.0) ) );
	else
		return 1.0;  -- function would be out-of-range-error
	end if;
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION DISTANCE_BATHTUB_WEIGHT(dist float)
   RETURNS float AS
$$
-- Calibration factors to make things suitable for transport modelling
DECLARE a_dist float:=0.1;
DECLARE shift_l float:=75;
DECLARE shift_r float:=350;
begin	
   if (dist < ((shift_l + shift_r) / 2)) then
        return (1 / (1 + exp( a_dist * (dist - shift_l)) ));
   elsif (dist >= ((shift_l + shift_r) / 2)) then
        return (1 / (1 + exp(-a_dist * (dist - shift_r)) ));    
   else
   		return -1; -- should not happen; just test if function works
   end if;
END;
$$ language 'plpgsql' STRICT;


-- Add a column with the respective impedances from the above functions
alter table lvm_od_onlybav add column IF NOT EXISTS ttime_weight float;
alter table lvm_od_onlybav add column IF NOT EXISTS distance_weight float;
alter table lvm_od_onlybav add column IF NOT EXISTS demand_weight float;

update only lvm_od_onlybav set 
	ttime_weight = TTIME_LOGIT_WEIGHT(TTIME_RATIO),
	distance_weight = DISTANCE_BATHTUB_WEIGHT(directdist),
	demand_weight = DEMAND_MAX_ADAPT_WEIGHT(Demand_all / 24);  --divide by number of flights to have PAX/flight (e.g. 1 flight/hour)

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



--- export csv (e.g. for histogram); run python script after this steps
COPY lvm_od_996286_cont_metric(cm_metric_scen1, cm_metric_scen2, cm_metric_scen3, ttime_weight, distance_weight, demand_weight, directdist, total_impedance1, total_impedance2, total_impedance3) TO 'C:\TUMdissDATA\cm_metric.csv' DELIMITER ',' CSV HEADER;


COPY lvm_od_onlybav(cm_metric_scen1, cm_metric_scen2, cm_metric_scen3, directdist, demand_ivoev, PAX_h_BASE, PAX_h_UAM_all) TO 'C:\TUMdissDATA\cm_metrics_with_PAXh.csv' DELIMITER ',' CSV HEADER;

