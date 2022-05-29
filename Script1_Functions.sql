


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


CREATE OR REPLACE FUNCTION TTIME_WEIGHT(TTR float) 
   RETURNS float AS
$$
DECLARE shift float :=1;
DECLARE a float=0.9;
DECLARE b float=3;
DECLARE c float=0.9;

BEGIN
   RETURN least((power((1+power(((TTR+shift)/c),b)),(-a))), 1);
	--RETURN least(TTR, 1);
END;
$$ language 'plpgsql' STRICT;





-- clear table
TRUNCATE TABLE UAM_TEST;

-- fill table
---- with no random
--INSERT INTO UAM_TEST select 2,2,2.0,2.0,1.0,2.0,2.0,2.0,2.0 FROM generate_series(1,100);

---- including random
INSERT INTO UAM_TEST select 2, 2, random_between(1,150), random_between(1,120), random_between(1,120), random_between(1,1000), random_between(1,1000) FROM generate_series(1,100);

---- with equations
update UAM_TEST set beeline_speed_put_kmh = directdist / ttime_put;
update UAM_TEST set ttime_ratio = TTIME_RATIO(ttime_put, ttime_prt);
update UAM_TEST set R_SCEN_2 = TTIME_WEIGHT(TTIME_RATIO);

-- show content
select * from UAM_TEST;

