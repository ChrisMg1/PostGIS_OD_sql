-- recoding of the weight functions (travel impedance) from python scripts. 
-- Goal: Continuous Metric for OD-connections

-- Script Part 1:

-- This script does the following
--- 1) defines the "factor functions" which calculate the "intermediate impedances" from the raw data
--- 2) creates new columns in the database to store those impedances
--- 3) applies the factor functions to fill the impedance columns
-- now we have the intermediate impedances. In further scripts the combined impedances, the total impedance and the utilities can be calculated. 


-- RUN whole script (not line by line); Maybe delete existing functions first. (takes ~ 5.5h)

DROP FUNCTION IF EXISTS CM_TTIME_LOGIT_WEIGHT;
CREATE OR REPLACE FUNCTION CM_TTIME_LOGIT_WEIGHT(
	TTR_in float8,
	in_p float8,
	in_a2 float8
	)
   RETURNS float8 AS
$$
BEGIN
   if (TTR_in > 3.0 * in_p) then  -- function would be out-of-range-error
        if (in_a2 >= 0.0) then
            return 0.0;
        elsif (in_a2 < 0.0) then
            return 1.0;
        else
            raise exception 'CM: Something wrong';
	    end if;
    elsif (TTR_in <= 3.0 * in_p) then
        return (1.0 / (1.0 + exp(in_a2 * (TTR_in - in_p)) ));
    else
        raise exception 'CM: Something wrong 1';
	end if;
   exception when others then 
        raise exception 'CM: Something wrong 2';
END;
$$ language 'plpgsql' STRICT;


DROP FUNCTION IF exists CM_DISTANCE_DEMAND_BATHTUB2ast; -- no redundant 'declare'
CREATE OR REPLACE FUNCTION CM_DISTANCE_DEMAND_BATHTUB2ast(
    in_dist_demand float8,
	in_shift_li float8,
    in_shift_re float8,
    in_a_dist_l float8,
    in_a_dist_r float8,
    transp float8,
    Nmultip float8
	)
RETURNS float8 AS
$$
DECLARE
   in_shift_l float8 := Nmultip * in_shift_li;
   in_shift_r float8 := Nmultip * in_shift_re;
BEGIN
   if (in_dist_demand > 2.0 * in_shift_r) then	-- avoid out-of-range errors; threshold is adjustable
		return 1.0;
   elsif (in_dist_demand <  ((in_shift_l + in_shift_r) * transp)) then
        return (1.0 / (1.0 + exp( in_a_dist_l * (in_dist_demand - in_shift_l)) ));
   elsif (in_dist_demand >= ((in_shift_l + in_shift_r) * transp)) then
        return (1.0 / (1.0 + exp(-in_a_dist_r * (in_dist_demand - in_shift_r)) ));
   else
   		return -1; -- should not happen; just test if function works
   end if;
   exception when others then 
        raise exception 'Value out of range for in_dist_demand= %', in_dist_demand;
END;
$$ language 'plpgsql' STRICT;


DROP FUNCTION IF exists CM_DEMAND_MAX_ADAPT_WEIGHT;
CREATE OR REPLACE FUNCTION CM_DEMAND_MAX_ADAPT_WEIGHT(
	imp float8
	)
RETURNS float8 AS
$$
-- Calibration factors to make things suitable for transport modelling
DECLARE d_m float8:=1.7034;
DECLARE w_m float8:=0.35;
DECLARE s_m float8:=0.0;
imp_in float8=(w_m*(imp - s_m));
begin
	if imp < 100.0 then
		RETURN (1.0 - d_m * ( sqrt(2.0/pi()) * imp_in * imp_in * exp(-imp_in * imp_in/2.0) ) );
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
	imp_distance = CM_DISTANCE_DEMAND_BATHTUB2ast(directdist, 60.0, 300.0, 0.1, 0.1, 0.5, 1.0),
    imp_demand = CM_DISTANCE_DEMAND_BATHTUB2ast(demand_all_person_purged, 288.0, 768.0, 0.02, 0.1, 0.65, 1.0);   -- min: 12 flight per day (4PAX * 12); max: Lukas paper: 32 PAX per hour (32*24); "old" was PAX per flight

    
-- RUN whole script (not line by line) !

-- todo: optimum demand prüfen; select...