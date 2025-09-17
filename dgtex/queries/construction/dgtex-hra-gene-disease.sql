.mode csv
WITH gene_to_phenotype AS (SELECT * FROM read_csv('raw-data/dgtex-gene-phenotype.csv')),
  asctb AS (SELECT * FROM read_csv('output-data/dgtex-hra-gene-evidence.csv'))

SELECT DISTINCT asctb.*, 
  gene_to_phenotype.hpo_name, gene_to_phenotype.hpo_id, gene_to_phenotype.disease_id, gene_to_phenotype.onset_name, gene_to_phenotype.onset_id
FROM asctb 
  INNER JOIN gene_to_phenotype ON (asctb.gene_label = gene_to_phenotype.gene_symbol)
ORDER BY asctb.gene_label, gene_to_phenotype.onset_name
