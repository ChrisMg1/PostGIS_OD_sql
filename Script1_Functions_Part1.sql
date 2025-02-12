-- recoding of the weight functions (travel impedance) from python scripts. 
-- Goal: Continuous Metric for OD-connections

-- RUN whole script (not line by line); Maybe delete existing functions first. 

CREATE OR REPLACE FUNCTION CM_TTIME_LOGIT_WEIGHT(
	TTR float8,
	in_p float8,
	in_a2 float8
	)
   RETURNS float8 AS
$$
DECLARE p_w float8 :=in_p;
DECLARE a2_w float8 :=in_a2;

BEGIN
   if TTR < 100.0 then
		RETURN (1.0 / (1.0 + exp(a2_w * (TTR - p_w)) ));
	else
		return 0.0;  -- function would be out-of-range-error
	end if;
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION CM_DISTANCE_DEMAND_BATHTUB2(
    in_dist_demand float8,
	in_shift_l float8, 
    in_shift_r float8, 
    in_a_dist_l float8,
    in_a_dist_r float8
	)
RETURNS float8 AS
$$
DECLARE
    v_shift_l float8 := in_shift_l;
    v_shift_r float8 := in_shift_r;
    v_a_dist_l float8 := in_a_dist_l;
    v_a_dist_r float8 := in_a_dist_r;
BEGIN
   if (in_dist_demand > 3.0 * v_shift_r) then	-- avoid out-of-range errors
		return 1;
   elsif (in_dist_demand < ((v_shift_l + v_shift_r) / 2)) then
        return (1.0 / (1.0 + exp( v_a_dist_l * (in_dist_demand - v_shift_l)) ));
   elsif (in_dist_demand >= ((v_shift_l + v_shift_r) / 2)) then
        return (1.0 / (1.0 + exp(-v_a_dist_r * (in_dist_demand - v_shift_r)) ));
   else
   		return -1; -- should not happen; just test if function works
   end if;
   exception when numeric_value_out_of_range then 
        raise exception 'Value out of range for in_dist_demand= %', in_dist_demand;
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
-- Temp for some double-checks and comparisons
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_ttime float8;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_distance float8;
alter table odpair_LVM2035_23712030_onlyBAV add column IF NOT EXISTS imp_demand float8;


-- Now: Bathtub function for both demand and distance impedance
update only odpair_LVM2035_23712030_onlyBAV set 
	imp_ttime = CM_TTIME_LOGIT_WEIGHT(ttime_ratio, 1.0, 5.0),
	imp_distance = CM_DISTANCE_DEMAND_BATHTUB2(directdist, 75.0, 350.0, 0.1, 0.1),
	imp_demand = CM_DISTANCE_DEMAND_BATHTUB2((demand_all_person_purged / 24.0), 2.0, 6.0, 4.0, 4.0);  --divide by number of flights per day to have PAX/flight (e.g. 1 flight/hour);



-- RUN whole script (not line by line) !

-- todo: optimum demand prüfen; select...

