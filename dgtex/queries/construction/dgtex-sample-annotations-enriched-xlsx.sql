INSTALL excel;
LOAD excel;

COPY (SELECT * FROM read_csv('output-data/dgtex-sample-annotations-enriched.csv')) TO 'output-data/dgtex-sample-annotations-enriched.xlsx' WITH (FORMAT xlsx, HEADER true);
