-- add spatial column

ALTER TABLE dauz ADD COLUMN geom_tangent geometry(multilinestring,4326);

-- add geometries and coordinate system

update dauz set geom = st_setsrid(st_makepoint(longitude, latitude), 4326)