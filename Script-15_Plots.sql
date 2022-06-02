-- lvm_od_996286_cont_metric
-- cm_metric

-- THANKS to Dmitri Fontaine from https://tapoueh.org/blog/2014/02/postgresql-aggregates-and-histograms/

CREATE OR REPLACE FUNCTION histogram(table_name_or_subquery text, column_name text)
RETURNS TABLE(bucket int, "range" numrange, freq bigint, bar text)
AS $func$
BEGIN
RETURN QUERY EXECUTE format('
  WITH
  source AS (
    SELECT * FROM %s
  ),
  min_max AS (
    SELECT min(%s) AS min, max(%s) AS max FROM source
  ),
  histogram AS (
    SELECT
      width_bucket(%s, min_max.min, min_max.max, 20) AS bucket,
      numrange(min(%s)::numeric, max(%s)::numeric, ''[]'') AS "range",
      count(%s) AS freq
    FROM source, min_max
    WHERE %s IS NOT NULL
    GROUP BY bucket
    ORDER BY bucket
  )
  SELECT
    bucket,
    "range",
    freq::bigint,
    repeat(''*'', (freq::float / (max(freq) over() + 1) * 15)::int) AS bar
  FROM histogram',
  table_name_or_subquery,
  column_name,
  column_name,
  column_name,
  column_name,
  column_name,
  column_name,
  column_name
  );
END
$func$ LANGUAGE plpgsql;

drop table  hist_test;

SELECT * into table hist_test FROM histogram('(SELECT * FROM lvm_od_996286_cont_metric) as foo', 'cm_metric');

select * from hist_test;

--select count(*) from lvm_od_996286;
--select count(*) from lvm_od_996286_cont_metric;
--select sum(freq) from hist_test;




