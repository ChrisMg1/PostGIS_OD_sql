-- add geometry column (line)
ALTER TABLE lvm_od 
  ADD COLUMN geom43
    geometry(Linestring);
   
-- fill geometry column 
UPDATE lvm_od set
	geom43= st_setsrid(
		st_makeline(
			st_makepoint(fromzone_xcoord,  fromzone_ycoord),
			st_makepoint(tozone_xcoord,  tozone_ycoord)
					), 4326
				);

			
			
			
-- add geometry column (points)
ALTER TABLE lvm_od 
  ADD COLUMN geom_point_toOD
    geometry(Point);

-- fill geometry column 
UPDATE lvm_od set
	geom_point_toOD = st_setsrid(
			st_makepoint(tozone_xcoord, tozone_ycoord), 4326
				);