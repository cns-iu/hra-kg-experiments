#!/bin/bash

export JAVA_OPTS="-Xms2g -Xmx96g"

duckdb -no-stdin -init queries/swat-genes.sql > output-data/swat-genes.csv

# Get the values to paste into .rq files
# tail -n +2 output-data/swat-genes.csv | tr -d '\r' | awk 'NF{printf "(\"%s\"^^xsd:string)%s", $0, (NR? " ":"")} END{print ""}' > paste-me
# exit

time ../bin/sparql-select-local.sh ../../hra-kg/dist/blazegraph.jnl queries/swat-hra-gene-evidence.rq output-data/swat-hra-gene-evidence.csv
time ../bin/sparql-select-local.sh ../../hra-kg/dist/blazegraph.jnl queries/cl-lookup.rq output-data/cl-lookup.csv

rm -f raw-data/swat.duckdb
duckdb raw-data/swat.duckdb -no-stdin -init queries/swat-clusters.sql

## skip
# time sparql-select-local.sh ../../hra-pop/raw-data/v1.1/blazegraph.jnl queries/swat-hra-pop-asctb-dataset-evidence.rq output-data/swat-hra-pop-asctb-dataset-evidence.csv
