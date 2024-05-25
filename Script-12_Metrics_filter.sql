--filter various travel time classes

-- Bad PuT travel time
DROP TABLE IF exists LVM_OD_bad_put_gt5p0;
DROP TABLE IF exists LVM_OD_bad_put_gt5p0and60km;


-- SElect 'bad' PuT OD-connections (Aktuell im Produktiv QGIS)
-- PArameters are arbitrar at this point; difficult to choose
SELECT
    *
INTO TABLE LVM_OD_bad_put_gt5p0and60km
FROM
    lvm_od_996286
WHERE
    TTime_ratio > 5.0
	AND fromzone_no != tozone_no
	AND fromzone_by = true
	and tozone_by = true
	and DIRECTDIST > 60;

-- Extract Points (from and to) from the latter subset to have a) proper labeling and b) vertices for further network generaltion
-- (Has to be performed for all further subsets)
-- union merges only unique points (use union all else). Information from/to is lost this way
Create table LVM_OD_bad_put_gt5p0and60km_merged as
Select fromzone_name, geom_point_fromod from LVM_OD_bad_put_gt5p0and60km
union
select tozone_name, geom_point_tood from LVM_OD_bad_put_gt5p0and60km;

SELECT
    *
INTO TABLE lvm_od_996286_cont_metric
FROM
    lvm_od_996286
WHERE
    fromzone_no != tozone_no
	--and directdist > 60
	AND fromzone_by = true
	and tozone_by = true;





SELECT
    *
INTO TABLE LVM_OD_bad_put_gt5p0
FROM
    lvm_od_996286
WHERE
    TTime_ratio > 5.0
	AND fromzone_no != tozone_no
	AND fromzone_by = true
	and tozone_by = true;

SELECT
    *
INTO TABLE LVM_OD_bad_put_gt2p0
FROM
    lvm_od_996286
WHERE
    TTime_ratio > 2.0
	AND fromzone_no != tozone_no
	AND fromzone_by = true
	and tozone_by = true;

SELECT
    *
INTO TABLE lvm_od_good_put_st1p0
FROM
    lvm_od_996286
WHERE
    TTime_ratio < 1.0
	AND fromzone_no != tozone_no	
	and (fromzone_by = true or tozone_by = true);

SELECT
    *
INTO TABLE lvm_od_good_put_st0p5
FROM
    lvm_od_996286
WHERE
    TTime_ratio < 0.5
	AND fromzone_no != tozone_no	
	and (fromzone_by = true or tozone_by = true);


SELECT
    *
INTO TABLE lvm_od_fast_put_st0p5_agg
FROM
    lvm_od_AKS_AGG
	where TTime_ratio < 0.5
	AND fromzone_aks != tozone_aks	
	and (fromzone_by = true or tozone_by = true);

-------------
-- Create different sub-tables as scenarios
-------------

-- Reisezeitverhältnis PuT/PrT
SELECT *
INTO TABLE lvm_od_AKS_AGG_st0p7
FROM lvm_od_AKS_AGG
where speed_ratio < 0.7
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

-- Gem�� RIN werden die beiden Metropolen (M+N, FFM ist au�erhalb) ausgew�hlt und noch Vor- und Nachlauf eingearbeitet. Nachfrage nicht ber�cksichtigt. 
SELECT *
INTO TABLE lvm_od_AKS_AGG_RIN1
FROM lvm_od_AKS_AGG
where (fromzone_aks = 9162 and tozone_aks = 9564) -- M�nchen -> N�rnberg
OR (fromzone_aks = 9564 and tozone_aks = 9162) -- N�rnberg -> M�nchen
OR (fromzone_aks = 9162 and directdist < 50) -- M�nchen access
OR (tozone_aks = 9162 and directdist < 50) -- M�nchen egress
OR (fromzone_aks = 9564 and directdist < 50) -- N�rnberg access
OR (tozone_aks = 9564 and directdist < 50) -- N�rnberg egress
;