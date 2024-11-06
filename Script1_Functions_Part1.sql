-- recoding of the weight functions (travel impedance) from python scripts. 
-- Goal: Continuous Metric for OD-connections

-- RUN whole script (not line by line)

CREATE OR REPLACE FUNCTION CM_TTIME_LOGIT_WEIGHT(TTR float)
   RETURNS float AS
$$
DECLARE p_w float :=1.0;
DECLARE a2_w float:=5.0;

BEGIN
   if TTR < 100.0 then
		RETURN (1.0 / (1.0 + exp(a2_w * (TTR - p_w)) ));
	else
		return 0.0;  -- function would be out-of-range-error
	end if;
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION CM_DISTANCE_BATHTUB_WEIGHT(dist float)
   RETURNS float AS
$$
-- Calibration factors to make things suitable for transport modelling
DECLARE shift_l float:=75.0;
DECLARE shift_r float:=350.0;
DECLARE a_dist_l float:=0.1;
DECLARE a_dist_r float:=0.1;
begin
   if (dist < ((shift_l + shift_r) / 2)) then
        return (1.0 / (1.0 + exp( a_dist_l * (dist - shift_l)) ));
   elsif (dist >= ((shift_l + shift_r) / 2)) then
        return (1.0 / (1.0 + exp(-a_dist_r * (dist - shift_r)) ));
   else
   		return -1; -- should not happen; just test if function works
   end if;
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION CM_DEMAND_MAX_ADAPT_WEIGHT(imp float)
   RETURNS float AS
$$
-- Calibration factors to make things suitable for transport modelling
DECLARE d_m float:=1.7034;
DECLARE w_m float:=0.35;
DECLARE s_m float:=0.0;
imp_in float=(w_m*(imp - s_m));
begin
	if imp < 100.0 then
		RETURN (1.0 - d_m*( sqrt(2.0/pi())*imp_in*imp_in*exp(-imp_in*imp_in/2.0) ) );
	else
		return 1.0;  -- function would be out-of-range-error
	end if;
END;
$$ language 'plpgsql' STRICT;


-- Add a column with the respective impedances from the above functions
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_ttime_temp float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_distance_temp float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_demand_temp float;

update only odpair_LVM2035_23712030_onlyBAV set 
	imp_ttime_temp = CM_TTIME_LOGIT_WEIGHT(ttime_ratio),
	imp_distance_temp = CM_DISTANCE_BATHTUB_WEIGHT(directdist),
	imp_demand_temp = CM_DEMAND_MAX_ADAPT_WEIGHT(demand_all_person_purged / 24.0);  --divide by number of flights per day to have PAX/flight (e.g. 1 flight/hour);




alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_ttime_abs float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_distance_abs float;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_demand_abs float;


update only odpair_LVM2035_23712030_onlyBAV set 
	imp_ttime_abs = abs(imp_ttime_temp - imp_ttime),
	imp_distance_abs = abs(imp_distance_temp - imp_distance),
	imp_demand_abs = abs(imp_demand_temp - imp_demand);

-- RUN whole script (not line by line) !

-- toto: optimum demand prüfen; select...

