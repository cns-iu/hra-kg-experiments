.mode csv
WITH onsets AS (SELECT * FROM read_csv('input-data/onsets.csv')),
  phenotype_to_genes AS (SELECT * FROM read_csv('raw-data/phenotype_to_genes.txt'))

SELECT DISTINCT gene_symbol, disease_id, hpo_name as onset_name, hpo_id as onset_id
FROM phenotype_to_genes
  INNER JOIN onsets ON (onsets.onset = phenotype_to_genes.hpo_id)
ORDER BY gene_symbol, disease_id
