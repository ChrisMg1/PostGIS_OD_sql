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
DECLARE shift float :=-1;
DECLARE a_w float:=0.9;
DECLARE b_w float:=3;
DECLARE c_w float:=0.9;

BEGIN
   RETURN least((power((1+power(((TTR+shift)/c_w),b_w)),(-a_w))), 1);
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION DEMAND_MAX_ADAPT_WEIGHT(imp float) 
   RETURNS float AS
$$
-- Calibration factors to make things suitable for transport modelling
DECLARE a_m float:=1.0;
DECLARE b_m float:=1.7;
DECLARE c_m float:=0.35;
imp_in float=imp*c_m;
begin	
   RETURN a_m-b_m*( sqrt(2/pi())*imp_in*imp_in*exp(-imp_in*imp_in/2.0) );
END;
$$ language 'plpgsql' STRICT;


CREATE OR REPLACE FUNCTION DISTANCE_BATHTUB_WEIGHT(dist float)
   RETURNS float AS
$$
-- Calibration factors to make things suitable for transport modelling
DECLARE a_dist float:=9;
DECLARE b_dist float:=3;
DECLARE c_dist float:=60;
DECLARE shift_l float:=-1;
DECLARE shift_r float:=-350;
begin	
	
	--!!todo: Translate and check
   if dist < 350 then
        return power((1+power(((dist+shift_l)/c_dist),b_dist)),(-a_dist));
   else
        return greatest(0, least(1, 1-(power((1+power(((dist+shift_r)/c_dist),b_dist) ),(-a_dist))) ) );    
   end if;
END;
$$ language 'plpgsql' STRICT;


-- clear table
TRUNCATE TABLE UAM_TEST;

-- fill table

---- including random
INSERT INTO UAM_TEST select 2, 2, random_between(10,1000), 1, 1, 3, 1 FROM generate_series(1,100);

---- with equations
update UAM_TEST set beeline_speed_put_kmh = directdist / ttime_put;
update UAM_TEST set ttime_ratio = TTIME_RATIO(ttime_put, ttime_prt);
update UAM_TEST set R_SCEN_1 = TTIME_LOGIT_WEIGHT(TTIME_RATIO);
update UAM_TEST set R_SCEN_2 = DEMAND_MAX_ADAPT_WEIGHT(demand_prt+demand_put);
update UAM_TEST set R_SCEN_3 = DISTANCE_BATHTUB_WEIGHT(directdist);

-- Work with the full table
-- Add a column with the value of the continous metric
--TODO: Maximum Value issue
alter table lvm_od_996286_cont_metric add column IF NOT EXISTS cm_metric float;
update only lvm_od_996286_cont_metric set cm_metric = TTIME_LOGIT_WEIGHT(TTIME_RATIO) + DISTANCE_BATHTUB_WEIGHT(directdist) + DEMAND_MAX_ADAPT_WEIGHT(Demand_all/100);

-- show content
select * from UAM_TEST;
select * from lvm_od_996286_cont_metric order by cm_metric asc;

