-- delete existing aggregated table
DROP TABLE IF EXISTS lvm_od_AKS_AGG;
DROP TABLE IF EXISTS lvm_od_AKS_AGG_st0p5;
DROP TABLE IF EXISTS lvm_od_AKS_AGG_st0p7;

-- group by Landkreise and aggegate other values (aggregate functions ton be cnd.)
-- new table name is lvm_od_AKS_AGG
SELECT
avg(fromzone_xcoord) as new_x_from,
avg(fromzone_ycoord) as new_y_from,
fromzone_aks,
max(fromzone_by),
avg(tozone_xcoord) as new_x_to,
avg(tozone_ycoord) as new_y_to,
tozone_aks,
max(tozone_by),
avg(directdist) as new_direct,
max(time_prt) as new_time_prt,
min(time_put) as new_time_put,
sum(demand_all) as new_all, 
sum(demand_ivoev) as new_ivoev,
(min(time_put) / max(time_prt)) as new_speed_ratio
INTO TABLE lvm_od_AKS_AGG
FROM lvm_od_996286
GROUP BY fromzone_aks, tozone_aks;


-- join Landkreis Names (Imported by QGIS => Processing => Database => PostGIS import)
-- todo: Evtl. in Mastertabelle schon machen
select SCH::DECIMAL, BEZ_KRS from lkr_ex order by SCH::DECIMAL;
select fromzone_aks, tozone_aks from lvm_od_AKS_AGG;

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
ADD COLUMN geom_point_new_from geometry(Point),
ADD COLUMN geom_point_new_to geometry(Point),
ADD COLUMN OD_new_connect geometry(Linestring);

-- fill new geometry columns
-- Bayern is UTM32 is EPSG:25832
UPDATE lvm_od_AKS_AGG
set geom_point_new_from = st_setsrid(st_makepoint(new_x_from, new_y_from), 25832);

UPDATE lvm_od_AKS_AGG
set geom_point_new_to = st_setsrid(st_makepoint(new_x_to, new_y_to), 25832);

UPDATE lvm_od_AKS_AGG
set	OD_new_connect = st_makeline(geom_point_new_from, geom_point_new_to);



-- Create different sub-tables as scenarios


SELECT *
INTO TABLE lvm_od_AKS_AGG_st0p7
FROM lvm_od_AKS_AGG
where new_speed_ratio < 0.7
AND fromzone_aks != tozone_aks;

-- optional: Perform checks
--select * from lvm_od_AKS_AGG;
--select count(*) from lvm_od_AKS_AGG;
select fromzone_aks, tozone_aks from lvm_od_AKS_AGG

select fromzone_aks, from_aks_name, tozone_aks, to_aks_name, new_all from lvm_od_aks_agg;