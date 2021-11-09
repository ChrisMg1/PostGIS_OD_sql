update gps_assetone set geom3= st_setsrid(st_makepoint(longitude / 1000000,  latitude / 1000000), 4326)



ALTER TABLE lvm_od 
  ADD COLUMN geom43
    geometry(Linestring);


UPDATE lvm_od set 
  geom43 = st_setsrid(ST_Transform(wkt_geom, 4326), 4326)
  WHERE ST_SRID(wkt_geom) = 4326;

UPDATE lvm_od set 
	geom43= st_setsrid(
		st_makeline(
			st_makepoint(fromzone_xcoord / 10000,  fromzone_ycoord / 100000),
			st_makepoint(tozone_xcoord / 10000,  tozone_ycoord / 100000)
					), 4326
				);


