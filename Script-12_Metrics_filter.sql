--filter various travel time classes

-- Bad PuT trvael time
DROP TABLE IF exists LVM_OD_bad_put

SELECT
    *
INTO TABLE LVM_OD_bad_put
FROM
    lvm_od_996286
WHERE
    speed_ratio > 15.0
	AND fromzone_no != tozone_no
	AND fromzone_by = true 
	and tozone_by = true;

select * from LVM_OD_bad_put order by speed_ratio asc;

SELECT
    *
INTO TABLE LVM_OD_badbad_put
FROM
    lvm_od_996286
WHERE
    speed_ratio > 20.0
	AND fromzone_no != tozone_no
	AND fromzone_by = true 
	and tozone_by = true;


SELECT
    *
INTO TABLE lvm_od_fast_put_st1p0
FROM
    lvm_od_996286
WHERE
    speed_ratio < 1.0
	AND fromzone_no != tozone_no	
	and (fromzone_by = true or tozone_by = true);

   
SELECT
    *
INTO TABLE lvm_od_fast_put_st0p7
FROM
    lvm_od_996286
	where speed_ratio < 0.7
	AND fromzone_no != tozone_no
	and (fromzone_by = true or tozone_by = true);


SELECT
    *
INTO TABLE lvm_od_fast_put_st0p5
FROM
    lvm_od_996286
	where speed_ratio < 0.5
	AND fromzone_no != tozone_no	
	and (fromzone_by = true or tozone_by = true);

SELECT
    *
INTO TABLE lvm_od_fast_put_st0p5_agg
FROM
    lvm_od_AKS_AGG
	where speed_ratio < 0.5
	AND fromzone_aks != tozone_aks	
	and (fromzone_by = true or tozone_by = true);

-------------
-- Create different sub-tables as scenarios
-------------

-- Reisezeitverhältnis ÖV/IV
SELECT *
INTO TABLE lvm_od_AKS_AGG_st0p7
FROM lvm_od_AKS_AGG
where new_speed_ratio < 0.7
AND fromzone_aks != tozone_aks;


-- nur Binnenverkehr Bayern (ohne Gürtel) 
SELECT *
INTO TABLE lvm_od_AKS_AGG_onlyBY
FROM lvm_od_AKS_AGG
where from_aks_name notnull
AND to_aks_name notnull;


-- von/nach Ingolstadt
SELECT *
INTO TABLE lvm_od_AKS_AGG_IN
FROM lvm_od_AKS_AGG
where from_aks_name like 'Ingolstadt'
OR to_aks_name like 'Ingolstadt';

-- Gemäß RIN werden die beiden Metropolen (M+N, FFM ist außerhalb) ausgewählt und noch Vor- und Nachlauf eingearbeitet. Nachfrage nicht berücksichtigt. 
SELECT *
INTO TABLE lvm_od_AKS_AGG_RIN1
FROM lvm_od_AKS_AGG
where (fromzone_aks = 9162 and tozone_aks = 9564) -- München -> Nürnberg
OR (fromzone_aks = 9564 and tozone_aks = 9162) -- Nürnberg -> München
OR (fromzone_aks = 9162 and new_direct < 50) -- München access
OR (tozone_aks = 9162 and new_direct < 50) -- München egress
OR (fromzone_aks = 9564 and new_direct < 50) -- Nürnberg access
OR (tozone_aks = 9564 and new_direct < 50) -- Nürnberg egress
;