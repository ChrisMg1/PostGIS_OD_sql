update gps_assetone set geom3= st_setsrid(st_makepoint(longitude / 1000000,  latitude / 1000000), 4326)


