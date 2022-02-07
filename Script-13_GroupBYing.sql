-- delete existing aggregated table
DROP TABLE IF EXISTS lvm_od_AKS_AGG;
DROP TABLE IF EXISTS lvm_od_AKS_AGG_st0p5;
DROP TABLE IF EXISTS lvm_od_AKS_AGG_st0p7;

-- group by Landkreise and aggegate other values (!!!! todo: aggregate functions ton be cnd.)
-- new table name is lvm_od_AKS_AGG
SELECT
--die aggregierte avg(fromzone) wird dann nicht verwendet, weil der centroid vom Landkreis als Q/Z Punkt gesetzt wird
avg(fromzone_xcoord) as fromzone_xcoord,
avg(fromzone_ycoord) as fromzone_ycoord,
fromzone_aks,
bool_or(fromzone_by) AS fromzone_by,
--die aggregierte avg(tozone) wird dann nicht verwendet, weil der centroid vom Landkreis als Q/Z Punkt gesetzt wird
avg(tozone_xcoord) as tozone_xcoord,
avg(tozone_ycoord) as tozone_ycoord,
tozone_aks,
bool_or(tozone_by) AS tozone_by,
avg(directdist) as directdist,
max(time_prt) as time_prt,
min(time_put) as time_put,
sum(demand_all) as demand_all, 
sum(demand_ivoev) as demand_ivoev,
(min(time_put) / max(time_prt)) as speed_ratio
INTO TABLE lvm_od_AKS_AGG
FROM lvm_od_996286
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
ALTER TABLE lvm_od_AKS_AGG
ADD COLUMN geom_point_fromOD geometry(Point),
ADD COLUMN geom_point_toOD geometry(Point),
ADD COLUMN ODconnect geometry(Linestring);





-- fill new geometry columns
-- Bayern is UTM32 is EPSG:25832
-- Zunächst Punkt auf Basis Mittelwerte, Lkr-Centroid dann im nächsten Schritt
UPDATE lvm_od_AKS_AGG
set geom_point_fromOD = st_setsrid(st_makepoint(fromzone_xcoord, fromzone_ycoord), 25832);

UPDATE lvm_od_AKS_AGG
set geom_point_toOD = st_setsrid(st_makepoint(tozone_xcoord, tozone_ycoord), 25832);



-- Es sollten die Landkreis-Centroids als from/to Punkte verwendet werden. 
-- Column wird daher geupdated, falls Infos aus Landkreis-Shape vorliegen (nur in Bayern)
update lvm_od_AKS_AGG
set geom_point_fromOD = st_centroid(lkr_ex.geom)
from lkr_ex
where lvm_od_AKS_AGG.fromzone_aks = lkr_ex.SCH::DECIMAL;

update lvm_od_AKS_AGG
set geom_point_toOD = st_centroid(lkr_ex.geom)
from lkr_ex
where lvm_od_AKS_AGG.tozone_aks = lkr_ex.SCH::DECIMAL;

-- Finally: Verbindungen erzeugen
UPDATE lvm_od_AKS_AGG
set	ODconnect = st_makeline(geom_point_fromOD, geom_point_toOD);

