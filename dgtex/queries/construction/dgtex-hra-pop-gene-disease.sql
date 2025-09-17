.mode csv
WITH gene_to_phenotype AS (SELECT * FROM read_csv('raw-data/dgtex-gene-phenotype.csv')),
  HRApop AS (SELECT * FROM read_csv('output-data/dgtex-hra-pop-gene-evidence.csv'))

SELECT DISTINCT HRApop.*, 
  gene_to_phenotype.hpo_name, gene_to_phenotype.hpo_id, gene_to_phenotype.disease_id --, gene_to_phenotype.onset_name, gene_to_phenotype.onset_id
FROM HRApop 
  INNER JOIN gene_to_phenotype ON (HRApop.gene_label = gene_to_phenotype.gene_symbol)
ORDER BY HRApop.gene_label, gene_to_phenotype.onset_name
