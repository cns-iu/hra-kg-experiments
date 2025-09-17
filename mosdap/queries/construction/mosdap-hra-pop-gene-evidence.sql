.mode csv
SELECT 
  first(gene_label) as gene_label, 
  first(ct_label) as ct_label,
  first(as_label) as as_label,
  AVG(mean_gene_expr) as avg_mean_gene_expr,
  SUM(cell_count) as cell_instance_count,
  COUNT(DISTINCT dataset) as dataset_count,
  "as", ct, gene
FROM read_csv('/dev/stdin')
GROUP BY "as", ct, gene
ORDER BY gene_label, avg_mean_gene_expr DESC, cell_instance_count DESC
