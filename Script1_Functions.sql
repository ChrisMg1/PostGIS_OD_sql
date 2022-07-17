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


CREATE OR REPLACE FUNCTION TTIME_RATIO(PuT float ,PrT float) 
   RETURNS float AS
$$
BEGIN
   RETURN PuT / PrT;
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION TTIME_LOGIT_WEIGHT(TTR float) 
   RETURNS float AS
$$
DECLARE p_w float :=2.5;
DECLARE a2_w float:=3.0;

BEGIN
   if TTR < 10000.0 then
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


-- clear and refill test table
--TRUNCATE TABLE UAM_TEST;
--INSERT INTO UAM_TEST select 2, 2, random_between(10,1000), 1, 1, 3, 1 FROM generate_series(1,100);

---- with equations
update UAM_TEST set beeline_speed_put_kmh = directdist / ttime_put;
update UAM_TEST set ttime_ratio = TTIME_RATIO(ttime_put, ttime_prt);
update UAM_TEST set R_SCEN_1 = TTIME_LOGIT_WEIGHT(TTIME_RATIO);
update UAM_TEST set R_SCEN_2 = DEMAND_MAX_ADAPT_WEIGHT(demand_prt+demand_put);
update UAM_TEST set R_SCEN_3 = DISTANCE_BATHTUB_WEIGHT(directdist);

-- Work with the full table
-- Add a column with the value of the continous metric
alter table lvm_od_996286_cont_metric add column IF NOT EXISTS ttime_weight float;
update only lvm_od_996286_cont_metric set ttime_weight = TTIME_LOGIT_WEIGHT(TTIME_RATIO);

alter table lvm_od_996286_cont_metric add column IF NOT EXISTS distance_weight float;
update only lvm_od_996286_cont_metric set distance_weight = DISTANCE_BATHTUB_WEIGHT(directdist);

alter table lvm_od_996286_cont_metric add column IF NOT EXISTS demand_weight float;
update only lvm_od_996286_cont_metric set demand_weight = DEMAND_MAX_ADAPT_WEIGHT(Demand_all);  --divide by number of flights to have PAX/flight (min at 4)

alter table lvm_od_996286_cont_metric add column IF NOT EXISTS cm_metric float;
update only lvm_od_996286_cont_metric set cm_metric = ( (0 * ttime_weight) + (0 * distance_weight) + (1 * demand_weight) ) / (0 + 0 + 1) ;


-- show content
select count(*) from lvm_od_996286_cont_metric where cm_metric < 0.1;
select count(*) from lvm_od_996286;
select * from lvm_od_996286_cont_metric order by directdist desc;


--- exprt csv (for histogram); run python script after this step
COPY lvm_od_996286_cont_metric(cm_metric, ttime_weight, distance_weight, demand_weight, directdist) TO 'C:\temp\cm_metric.csv' DELIMITER ',' CSV HEADER;
