CREATE INDEX dauz_idx
  ON dauz
  USING GIST (geom);
  
-- DROP INDEX gps_idx;
 
 
 SELECT DISTINCT ON (dauz.bast_id) dauz.bast_id, strassen_polyline2.abs, ST_Distance(ST_SetSRID(ST_Makepoint(p.x, p.y),4326), dauz.geom)
FROM points dauz
    LEFT JOIN roads r ON ST_DWithin(ST_SetSRID(ST_Makepoint(p.x, p.y),4326), r.geom, 30.48)
ORDER BY p.id, ST_Distance(ST_SetSRID(ST_Makepoint(p.x, p.y),4326), r.geom);