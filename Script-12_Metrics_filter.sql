--filter various travel time classes
SELECT
    *
INTO TABLE lvm_od_fast_put_st1p0
FROM
    lvm_od_996286
WHERE
    speed_ratio < 1.0
AND fromzone_no != tozone_no;

   
SELECT
    *
INTO TABLE lvm_od_fast_put_st0p7
FROM
    lvm_od_996286
WHERE
    speed_ratio < 0.7
AND fromzone_no != tozone_no;


SELECT
    *
INTO TABLE lvm_od_fast_put_st0p5
FROM
    lvm_od_996286
WHERE
    speed_ratio < 0.5
AND fromzone_no != tozone_no;
