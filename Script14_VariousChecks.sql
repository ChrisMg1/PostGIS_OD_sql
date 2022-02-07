----

-- optional: Perform checks
select * from lvm_od_AKS_AGG;
select count(*) from lvm_od_AKS_AGG_onlyBY;
select fromzone_aks, tozone_aks from lvm_od_AKS_AGG;
select fromzone_name, fromzone_ags, fromzone_aks from lvm_od_996286;
select fromzone_aks, from_aks_name, tozone_aks, to_aks_name, new_all from lvm_od_aks_agg;

select count(*) from lvm_od_AKS_AGG;
select count(tozone_aks) from lvm_od_AKS_AGG;
select count(distinct fromzone_aks) from lvm_od_AKS_AGG;
select distinct new_direct from lvm_od_AKS_AGG order by new_direct desc;
select distinct fromzone_aks from lvm_od_996286 order by fromzone_aks asc;
select SCH::DECIMAL, BEZ_KRS from lkr_ex order by SCH::DECIMAL;
select from_aks_name, to_aks_name from lvm_od_AKS_AGG;
select SCH::DECIMAL from lkr_ex;