#!/bin/bash
set -ev

PATH=../bin:$PATH
export JAVA_OPTS="-Xms2g -Xmx64g"
LOD=https://lod.humanatlas.io/sparql

# Cleanup directories with --clean
if [ "$1" == "--clean" ]; then
  rm raw-data/*.csv raw-data/*.txt output-data/*.csv raw-data/*.csv.gz output-data/*.csv.gz
fi

# Download external data

# Download HRApop blazegraph journal
if [ ! -e raw-data/hra-kg-blazegraph.jnl ]; then
  curl -o raw-data/hra-kg-blazegraph.jnl https://cdn.humanatlas.io/digital-objects/blazegraph.jnl
fi

# Download phenotype to gene mappings from HPO
if [ ! -e raw-data/phenotype_to_genes.txt ]; then
  curl -o raw-data/phenotype_to_genes.txt -L https://github.com/obophenotype/human-phenotype-ontology/releases/download/v2025-09-01/phenotype_to_genes.txt
fi

# Download HRApop blazegraph journal
if [ ! -e raw-data/hra-pop-blazegraph.jnl ]; then
  curl -o raw-data/hra-pop-blazegraph.jnl https://cdn.humanatlas.io/dvc/hra-pop/raw-data/v1.0/blazegraph.jnl
fi

# Run queries

# Get all possible phenotypes from HPO
sparql-select.sh $LOD queries/construction/all-phenotypes.rq > raw-data/all-phenotypes.csv

# Get hp-uberon relationships from HPO
sparql-select-local.sh raw-data/hra-kg-blazegraph.jnl queries/construction/dgtex-phenotype-asct.rq output-data/dgtex-phenotype-asct.csv

# Extract gene->disease with developmental onset mapping
cat queries/construction/dgtex-gene-disease.sql | duckdb | csvformat > raw-data/dgtex-gene-disease.csv

# Extract gene->phenotype with developmental onset mapping
cat queries/construction/dgtex-gene-phenotype.sql | duckdb | csvformat > raw-data/dgtex-gene-phenotype.csv

# Get ASCT+B relations related to the UBERON terms in input-data/dgtex-sample-annotations.csv
sparql-select.sh $LOD queries/construction/dgtex-hra-gene-evidence.rq > output-data/dgtex-hra-gene-evidence.csv

# Limit evidence genes tied to disease/phenotype on HPO
cat queries/construction/dgtex-hra-gene-disease.sql | duckdb | csvformat > output-data/dgtex-hra-gene-disease.csv

# Get HRApop dataset ASCT+B relations related to the UBERON terms in input-data/dgtex-sample-annotations.csv
sparql-select-local.sh raw-data/hra-pop-blazegraph.jnl queries/construction/dgtex-hra-pop-asctb-dataset-evidence.rq raw-data/dgtex-hra-pop-asctb-dataset-evidence.csv
rm -f raw-data/dgtex-hra-pop-asctb-dataset-evidence.csv.gz
gzip -k raw-data/dgtex-hra-pop-asctb-dataset-evidence.csv

# Aggregate HRApop dataset relations
sql-select.sh queries/construction/dgtex-hra-pop-gene-evidence.sql raw-data/dgtex-hra-pop-asctb-dataset-evidence.csv output-data/dgtex-hra-pop-gene-evidence.csv

# Limit evidence genes tied to disease/phenotype on HPO
cat queries/construction/dgtex-hra-pop-gene-disease.sql | duckdb | csvformat > output-data/dgtex-hra-pop-gene-disease.csv
rm -f output-data/dgtex-hra-pop-gene-disease.csv.gz
gzip -k output-data/dgtex-hra-pop-gene-disease.csv

# Enrich the input annotations with data we gathered here
cat queries/construction/dgtex-sample-annotations-enriched.sql | duckdb | csvformat | perl -pe 's/http\:\/\/purl\.obolibrary\.org\/obo\/UBERON\_/UBERON:/g;s/http\:\/\/purl\.obolibrary\.org\/obo\/CL\_/CL:/g' > output-data/dgtex-sample-annotations-enriched.csv
