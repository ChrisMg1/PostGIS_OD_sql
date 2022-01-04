SELECT 
fromzone_aks, 
avg(fromzone_xcoord) as new_x_from
avg(fromzone_ycoord) as new_y_from
tozone_aks, 
avg(tozone_xcoord) as new_x_to
avg(tozone_ycoord) as new_y_to
sum(demand_put) as new_put, 
sum(demand_all) as new_dem, 
avg(time_prt) as new_tim_prt, 
avg(time_put) as new_time_put
INTO TABLE lvm_od_AKS_AGG8
FROM lvm_od_996286
GROUP BY fromzone_aks, tozone_aks

select * from lvm_od_AKS_AGG8;


SELECT
	DISTINCT fromzone_aks, tozone_aks
INTO TABLE lvm_od_AKS_AGG2
FROM lvm_od_996286
ORDER BY
	bcolor,
	fcolor;