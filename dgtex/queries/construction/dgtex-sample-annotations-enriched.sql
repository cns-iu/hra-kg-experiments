.mode csv
WITH HRAdisease AS (
  SELECT string_agg(DISTINCT gene_label, '|' ORDER BY gene_label) AS hra_disease_genes,
    string_agg(DISTINCT hpo_name, '|' ORDER BY hpo_name) AS hra_gene_diseases,
      "as"
  FROM read_csv('output-data/dgtex-hra-gene-disease.csv')
  GROUP BY "as"
),
HRApopDisease AS (
  SELECT string_agg(DISTINCT gene_label, '|' ORDER BY gene_label) AS hra_pop_disease_genes,
    string_agg(DISTINCT hpo_name, '|' ORDER BY hpo_name) AS hra_pop_gene_diseases,
    "as"
  FROM read_csv('output-data/dgtex-hra-pop-gene-disease.csv')
  GROUP BY "as"
),
HRA AS (
  SELECT string_agg(DISTINCT gene_label, '|' ORDER BY gene_label) AS hra_genes,
      "as"
  FROM read_csv('output-data/dgtex-hra-gene-evidence.csv')
  GROUP BY "as"
),
HRApop AS (
  SELECT string_agg(DISTINCT gene_label, '|' ORDER BY gene_label) AS hra_pop_genes,
    "as"
  FROM read_csv('output-data/dgtex-hra-pop-gene-evidence.csv')
  GROUP BY "as"
),
HPO AS (
  SELECT string_agg(DISTINCT phenotype_label, '|' ORDER BY phenotype_label) AS hpo_phenotypes,
      "as"
  FROM read_csv('output-data/dgtex-phenotype-asct.csv') AS hp
    INNER JOIN read_csv('raw-data/dgtex-gene-phenotype.csv') AS pheno 
    ON (hp.phenotype = pheno.hpo_id)
  GROUP BY "as"
),
annotations AS MATERIALIZED (SELECT * FROM read_csv('input-data/dgtex-sample-annotations.csv'))

SELECT DISTINCT annotations.*,
  HPO_smtsd.hpo_phenotypes AS SMTSD_hpo_phenotypes,
  HRA_smtsd.hra_genes AS SMTSD_hra_genes,
  HRApop_smtsd.hra_pop_genes AS SMTSD_hra_pop_genes,
  HRAdisease_smtsd.hra_disease_genes AS SMTSD_hra_disease_genes,
  HRApopDisease_smtsd.hra_pop_disease_genes AS SMTSD_hra_pop_disease_genes,
  HRAdisease_smtsd.hra_gene_diseases AS SMTSD_hra_gene_diseases,
  HRApopDisease_smtsd.hra_pop_gene_diseases AS SMTSD_hra_pop_gene_diseases,

  HPO_smts.hpo_phenotypes AS SMTS_hpo_phenotypes,
  HRA_smts.hra_genes AS SMTS_hra_genes,
  HRApop_smts.hra_pop_genes AS SMTS_hra_pop_genes,
  HRAdisease_smts.hra_disease_genes AS SMTS_hra_disease_genes,
  HRApopDisease_smts.hra_pop_disease_genes AS SMTS_hra_pop_disease_genes,
  HRAdisease_smts.hra_gene_diseases AS SMTS_hra_gene_diseases,
  HRApopDisease_smts.hra_pop_gene_diseases AS SMTS_hra_pop_gene_diseases,

FROM annotations
  LEFT OUTER JOIN HRA AS HRA_smts ON (annotations.SMTSUBRID = HRA_smts."as")
  LEFT OUTER JOIN HRApop AS HRApop_smts ON (annotations.SMTSUBRID = HRApop_smts."as")
  LEFT OUTER JOIN HRAdisease AS HRAdisease_smts ON (annotations.SMTSUBRID = HRAdisease_smts."as")
  LEFT OUTER JOIN HRApopDisease AS HRApopDisease_smts ON (annotations.SMTSUBRID = HRApopDisease_smts."as")
  LEFT OUTER JOIN HPO AS HPO_smts ON (annotations.SMTSUBRID = HPO_smts."as")

  LEFT OUTER JOIN HRA AS HRA_smtsd ON (annotations.SMTSDUBRID = HRA_smtsd."as")
  LEFT OUTER JOIN HRApop AS HRApop_smtsd ON (annotations.SMTSDUBRID = HRApop_smtsd."as")
  LEFT OUTER JOIN HRAdisease AS HRAdisease_smtsd ON (annotations.SMTSDUBRID = HRAdisease_smtsd."as")
  LEFT OUTER JOIN HRApopDisease AS HRApopDisease_smtsd ON (annotations.SMTSDUBRID = HRApopDisease_smtsd."as")
  LEFT OUTER JOIN HPO AS HPO_smtsd ON (annotations.SMTSDUBRID = HPO_smtsd."as")
ORDER BY annotations.row
