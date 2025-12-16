.mode csv

SELECT DISTINCT(
    UNNEST(split (CONCAT_WS('|', * COLUMNS ('marker*')), '|'))
  ) AS marker
FROM (
  SELECT * FROM read_csv ('input-data/leiden_sub-azimuth_label-report.csv')
)
ORDER BY marker;
