
-- lvm_od_996286_cont_metric
-- cm_metric


with drb_stats as (
    select 
    		min(cm_metric) as min,
          	max(cm_metric) as max
      from lvm_od_996286_cont_metric
),
     histogram as (
   select width_bucket(cm_metric, min, max, 20) as bucket,
          --int4range(min(cm_metric), max(cm_metric), '[]') as range,
   			int4range(0, 3) as range,

          count(*) as freq
     from lvm_od_996286_cont_metric, drb_stats
 group by bucket
 order by bucket
)
 select bucket, range, freq,
        repeat('x',
               (   freq::float
                 / max(freq) over()
                 * 30
               )::int
        ) as bar
   from histogram;
   