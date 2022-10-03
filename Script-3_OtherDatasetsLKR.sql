


-- Subset on Bavaria
select *
into table Verkehrs_und_Sonderlandeplaetze_BY
from verkehrs_und_sonder_parsed
where "bundes-land" = 'BY';

select *
into table segelflug_by
from "Segelflug_parsed"
where "bundesland" = 'Bayern';


-- fit coordinate systems
ALTER TABLE verkehrs_und_sonder_parsed
  ALTER COLUMN geom 
  TYPE Geometry(Point, 32632) 
  USING ST_Transform(geom, 32632);
 
ALTER TABLE "Segelflug_parsed"
 ALTER COLUMN geom 
 TYPE Geometry(Point, 32632) 
 USING ST_Transform(geom, 32632);

ALTER TABLE "Verkehrsflughaefen"
 ALTER COLUMN geom 
 TYPE Geometry(Point, 32632) 
 USING ST_Transform(geom, 32632);

ALTER TABLE "lkr_ex_by"
 ALTER COLUMN geom 
 TYPE Geometry(MultiPolygon, 32632) 
 USING ST_Transform(geom, 32632);


ALTER TABLE nearest_airport
ADD COLUMN geom2 geometry(Linestring);

ALTER TABLE nearest_airport
DROP COLUMN geom;

update nearest_airport
set geom2 = st_makeline(st_setsrid(st_makepoint(feature_x, feature_y), 32632), st_setsrid(st_makepoint(nearest_x, nearest_y), 32632) );

