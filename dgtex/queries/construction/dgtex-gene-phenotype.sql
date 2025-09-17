.mode csv
WITH diseases AS (SELECT * FROM read_csv('raw-data/dgtex-gene-disease.csv')),
  phenotypes AS (SELECT * FROM read_csv('raw-data/all-phenotypes.csv')),
  phenotype_to_genes AS (SELECT * FROM read_csv('raw-data/phenotype_to_genes.txt'))

SELECT DISTINCT phenotype_to_genes.gene_symbol, phenotype_to_genes.hpo_name, phenotype_to_genes.hpo_id,
  diseases.disease_id, diseases.onset_name, diseases.onset_id
FROM phenotype_to_genes
  INNER JOIN diseases ON (diseases.disease_id = phenotype_to_genes.disease_id)
  INNER JOIN phenotypes ON (phenotypes.phenotype = phenotype_to_genes.hpo_id)
ORDER BY phenotype_to_genes.gene_symbol, phenotype_to_genes.hpo_id
