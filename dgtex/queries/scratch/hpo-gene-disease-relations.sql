
.mode csv
SELECT DISTINCT HL.gene_name, HL.hgnc, GP.hpo_name, GP.hpo_id, GP.disease_id
FROM read_csv('https://apps.humanatlas.io/api/grlc/hra/ensembl-lookup.csv') AS HL
  INNER JOIN 
    read_csv("https://github.com/obophenotype/human-phenotype-ontology/releases/download/v2025-09-01/phenotype_to_genes.txt") AS GP
  ON (HL.gene_name = GP.gene_symbol)
ORDER BY HL.gene_name
