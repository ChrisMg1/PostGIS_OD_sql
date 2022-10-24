-- delete existing aggregated table
DROP TABLE IF EXISTS scen1_gt0p6;
DROP TABLE IF EXISTS scen1_gt0p6_AKS_AGG;


-- create new table with subset according to scenario
SELECT * INTO TABLE scen1_gt0p6 FROM lvm_od_onlybav WHERE cm_metric_scen1 >= 0.6 and demand_all >= 1;

-- make a column that allows grouping despite back and forth (AKS; landkreis);
ALTER TABLE scen1_gt0p6	ADD COLUMN from_to_aks text;
UPDATE scen1_gt0p6 set from_to_aks = concat(LEAST(fromzone_aks, tozone_aks), ' ', GREATEST(fromzone_aks, tozone_aks));


-- next step: Aggregate

-- group by Landkreise and aggegate other values (!!!! todo: aggregate functions ton be cnd.)
-- new table name is lvm_od_AKS_AGG
SELECT
--die aggregierte avg(fromzone) wird dann nicht verwendet, weil der centroid vom Landkreis als Q/Z Punkt gesetzt wird
avg(fromzone_xcoord) as fromzone_xcoord,
avg(fromzone_ycoord) as fromzone_ycoord,
--fromzone_aks,
max(fromzone_by) as fromzone_by,
--die aggregierte avg(tozone) wird dann nicht verwendet, weil der centroid vom Landkreis als Q/Z Punkt gesetzt wird
avg(tozone_xcoord) as tozone_xcoord,
avg(tozone_ycoord) as tozone_ycoord,
--tozone_aks,
max(tozone_by) as tozone_by,
avg(directdist) as directdist,
max(ttime_prt) as time_prt,
min(ttime_put) as time_put,
sum(demand_all) as demand_all, 
sum(demand_ivoev) as demand_ivoev
INTO TABLE scen1_gt0p6_AKS_AGG
FROM scen1_gt0p6
GROUP BY fromzone_aks, tozone_aks;

-- join Landkreis Names (Imported by QGIS => Processing => Toolbox => Database => PostGIS import)
-- todo: Evtl. in Mastertabelle schon machen
alter table lvm_od_AKS_AGG
add from_aks_name text,
add to_aks_name text;

update lvm_od_AKS_AGG
set from_aks_name = lkr_ex.bez_krs
from lkr_ex
where lvm_od_AKS_AGG.fromzone_aks = lkr_ex.SCH::DECIMAL;

update lvm_od_AKS_AGG
set to_aks_name = lkr_ex.bez_krs
from lkr_ex
where lvm_od_AKS_AGG.tozone_aks = lkr_ex.SCH::DECIMAL;


-- add new geometry columns (points and line)
ALTER TABLE scen1_gt0p6_AKS_AGG
ADD COLUMN geom_point_fromOD geometry(Point),
ADD COLUMN geom_point_toOD geometry(Point),
ADD COLUMN ODconnect geometry(Linestring);


-- fill new geometry columns
-- Bayern is UTM32 is EPSG:25832
-- Zunächst Punkt auf Basis Mittelwerte, Lkr-Centroid dann im nächsten Schritt

UPDATE scen1_gt0p6_AKS_AGG set
	geom_point_fromOD = st_setsrid(st_makepoint(fromzone_xcoord, fromzone_ycoord), 32632),
	geom_point_toOD = st_setsrid(st_makepoint(tozone_xcoord, tozone_ycoord), 32632);


-- Es sollten die Landkreis-Centroids als from/to Punkte verwendet werden. 
-- Column wird daher geupdated, falls Infos aus Landkreis-Shape vorliegen (nur in Bayern)

-- !! istr eine option von mehreren, AVG() ist durchaus auch legitim
update lvm_od_AKS_AGG
set geom_point_fromOD = st_centroid(lkr_ex.geom)
from lkr_ex
where lvm_od_AKS_AGG.fromzone_aks = lkr_ex.SCH::DECIMAL;

update lvm_od_AKS_AGG
set geom_point_toOD = st_centroid(lkr_ex.geom)
from lkr_ex
where lvm_od_AKS_AGG.tozone_aks = lkr_ex.SCH::DECIMAL;

-- Finally: Verbindungen erzeugen
UPDATE scen1_gt0p6_AKS_AGG
	set	ODconnect = st_makeline(geom_point_fromOD, geom_point_toOD);


