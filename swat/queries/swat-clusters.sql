-- Reference data

ATTACH 'input-data/dcta-db.duckdb' AS hra_pop_db (READ_ONLY);

CREATE OR REPLACE TABLE cl_lookup AS 
  SELECT * FROM read_csv('raw-data/cl-lookup.csv');

CREATE OR REPLACE TABLE swat_source AS
  SELECT * FROM read_csv('input-data/leiden_sub-azimuth_label-report.csv');


-- Long tables

CREATE OR REPLACE TABLE swat AS
  SELECT leiden_sub, split(concat_ws('|',*COLUMNS('marker*')),'|') AS markers
  FROM swat_source;

CREATE OR REPLACE TABLE hra_pop AS 
  SELECT cell_source, annotation_method, cell_id, cell_label, list_distinct(array_slice(list(marker), 0, 30)) AS markers 
  FROM (SELECT *, gene_expr.gene_label AS marker FROM hra_pop_db.cell_summaries)
  GROUP BY cell_source, annotation_method, cell_id, cell_label;

CREATE OR REPLACE TABLE hra_pop_nsforest AS 
  SELECT cell_source, annotation_method, cell_id, cell_label, list_distinct(list(marker)) AS markers 
  FROM (SELECT *, nsforest_gene_expr.gene_label AS marker FROM hra_pop_db.cell_summaries)
  GROUP BY cell_source, annotation_method, cell_id, cell_label;

CREATE OR REPLACE TABLE asctb AS
  SELECT asctb_table, cell_id, cell_label, split("references", '; ') AS refs, split(gene_symbols, '; ') AS markers
  FROM read_csv('output-data/swat-hra-gene-evidence.csv');


-- Evidence tables

CREATE OR REPLACE TABLE hra_pop_evidence AS
  SELECT leiden_sub,cell_id,
    coalesce(first(cl_lookup.label), first(cell_label)) AS cell_label,
    sum(length(array_intersect(swat.markers, hra_pop.markers))) AS evidence,
    count(distinct(cell_source)) AS dataset_count,
    list_aggregate(array_distinct(flatten(list(array_intersect(swat.markers, hra_pop.markers)))), 'string_agg', '; ') AS shared_markers,
    list_aggregate(array_distinct(flatten(list(hra_pop.markers))), 'string_agg', '; ') AS gene_expr_markers,
  FROM swat INNER JOIN hra_pop on (length(array_intersect(swat.markers, hra_pop.markers)) > 2)
    LEFT OUTER JOIN cl_lookup on (cl_lookup.id = hra_pop.cell_id)
  GROUP BY leiden_sub,cell_id
  ORDER BY leiden_sub,evidence DESC;

CREATE OR REPLACE TABLE hra_pop_nsforest_evidence AS
  SELECT leiden_sub,cell_id,
    coalesce(first(cl_lookup.label), first(cell_label)) AS cell_label,
    sum(length(array_intersect(swat.markers, hra_pop_nsforest.markers))) AS evidence,
    count(distinct(cell_source)) AS dataset_count,
    list_aggregate(array_distinct(flatten(list(array_intersect(swat.markers, hra_pop_nsforest.markers)))), 'string_agg', '; ') AS shared_markers,
    list_aggregate(array_distinct(flatten(list(hra_pop_nsforest.markers))), 'string_agg', '; ') AS gene_expr_markers,
  FROM swat INNER JOIN hra_pop_nsforest on (length(array_intersect(swat.markers, hra_pop_nsforest.markers)) > 0)
    LEFT OUTER JOIN cl_lookup on (cl_lookup.id = hra_pop_nsforest.cell_id)
  GROUP BY leiden_sub,cell_id
  ORDER BY leiden_sub,evidence DESC;

CREATE OR REPLACE TABLE asctb_evidence AS
  SELECT leiden_sub,cell_id,
    first(cell_label) AS cell_label,
    sum(length(array_intersect(swat.markers, asctb.markers))) AS evidence,
    group_concat(distinct(asctb_table), '; ') AS table,
    count(distinct(asctb_table)) AS table_count,
    list_aggregate(array_distinct(flatten(list(asctb.refs))), 'string_agg', '; ') AS "references",
    list_aggregate(array_distinct(flatten(list(array_intersect(swat.markers, asctb.markers)))), 'string_agg', '; ') AS shared_markers,
    list_aggregate(array_distinct(flatten(list(asctb.markers))), 'string_agg', '; ') AS asctb_markers,
  FROM swat INNER JOIN asctb on (length(array_intersect(swat.markers, asctb.markers)) > 0)
  GROUP BY leiden_sub,cell_id
  ORDER BY leiden_sub,evidence DESC;

COPY hra_pop_evidence TO 'output-data/leiden_sub-hra_pop_geneexpr-evidence.csv';
COPY hra_pop_nsforest_evidence TO 'output-data/leiden_sub-hra_pop_nsforest-evidence.csv';
COPY asctb_evidence TO 'output-data/leiden_sub-asctb-evidence.csv';


-- Reports

CREATE OR REPLACE TABLE hra_pop_report AS
  SELECT leiden_sub, 
    coalesce(cell[1], '') as hra_pop_gene_expr_1,
    coalesce(cell[2], '') as hra_pop_gene_expr_2,
    coalesce(cell[3], '') as hra_pop_gene_expr_3,
    coalesce(cell[4], '') as hra_pop_gene_expr_4,
    coalesce(cell[5], '') as hra_pop_gene_expr_5
  FROM (
    SELECT leiden_sub,
      max_by(concat(cell_label, ' (', cell_id, ')[', evidence, ' bg][', dataset_count, ' ds]'), evidence, 5) AS cell
    FROM hra_pop_evidence
    GROUP BY leiden_sub
  )
  ORDER BY leiden_sub;

CREATE OR REPLACE TABLE hra_pop_nsforest_report AS
  SELECT leiden_sub, 
    coalesce(cell[1], '') as hra_pop_nsforest_1,
    coalesce(cell[2], '') as hra_pop_nsforest_2,
    coalesce(cell[3], '') as hra_pop_nsforest_3,
    coalesce(cell[4], '') as hra_pop_nsforest_4,
    coalesce(cell[5], '') as hra_pop_nsforest_5
  FROM (
    SELECT leiden_sub,
      max_by(concat(cell_label, ' (', cell_id, ')[', evidence, ' bg][', dataset_count, ' ds]'), evidence, 5) AS cell
    FROM hra_pop_nsforest_evidence
    GROUP BY leiden_sub
  )
  ORDER BY leiden_sub;


CREATE OR REPLACE TABLE asctb_report AS
  SELECT swat_source.leiden_sub, 
    coalesce(cell[1], '') as asctb_1,
    coalesce(cell[2], '') as asctb_2,
    coalesce(cell[3], '') as asctb_3,
    coalesce(cell[4], '') as asctb_4,
    coalesce(cell[5], '') as asctb_5,
    coalesce(refs[1], '') as asctb_refs_1,
    coalesce(refs[1], '') as asctb_refs_2,
    coalesce(refs[1], '') as asctb_refs_3,
    coalesce(refs[1], '') as asctb_refs_4,
    coalesce(refs[1], '') as asctb_refs_5
  FROM swat_source LEFT OUTER JOIN (
    SELECT leiden_sub, 
      max_by(concat(cell_label, ' (', cell_id, ')[', evidence, ' bg][', "table", ']'), evidence, 5) AS cell,
      max_by("references", evidence, 5) AS refs
    FROM asctb_evidence
    GROUP BY leiden_sub
  ) USING (leiden_sub)
  ORDER BY leiden_sub;


COPY hra_pop_report TO 'output-data/leiden_sub-hra_pop_geneexpr-report.csv';
COPY hra_pop_nsforest_report TO 'output-data/leiden_sub-hra_pop_nsforest-report.csv';
COPY asctb_report TO 'output-data/leiden_sub-asctb-report.csv';
