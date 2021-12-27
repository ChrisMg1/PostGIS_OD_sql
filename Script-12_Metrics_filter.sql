--filter
SELECT
    *
INTO TABLE lvm_od_fast_put
FROM
    lvm_od_996286
WHERE
    speed_ratio < 0.3
AND fromzone_no != tozone_no;
--ORDER BY title;
   
   select count(*) from lvm_od_fast_put;