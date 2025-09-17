# dGTEx - HRA connections

This project was used to gather dGTEx relevant data from HRA and related resources to
inform the further development of dGTEx. The dGTEX sample locations are annotated with
UBERON terms which are used to lookup related data.

## Data Products

* [dGTEX Sample Annotations - Enriched from HRA related resources](output-data/dgtex-sample-annotations-enriched.csv) - The original tissue sample locations annotated with relevant data gathered from HRA, HRApop, and HPO.
* [HRA ASCT+B Gene -> Disease](output-data/dgtex-hra-gene-disease.csv) - ASCT+B Gene -> Disease relationships limited to the dGTEx sample locations and developmental onset for the diseases.
* [HRA ASCT+B Gene Evidence](output-data/dgtex-hra-gene-evidence.csv) - ASCT+B Gene relationships limited to the dGTEx sample locations.
* [HRApop ASCT+B Gene -> Disease](output-data/dgtex-hra-pop-gene-disease.csv.gz) - ASCT+B Gene -> Disease relationships derived from experimental data (HRApop) limited to the dGTEx sample locations and developmental onset for the diseases.
* [HRApop ASCT+B Gene Evidence](output-data/dgtex-hra-pop-gene-evidence.csv) - ASCT+B Gene relationships derived from experimental data (HRApop) limited to the dGTEx sample locations.
* [HPO Phenotype -> AS or CT](output-data/dgtex-phenotype-asct.csv) - Phenotype -> Anatomical Location or Cell Type limited to dGTEX sample locations.

## Directories

* [`input-data`](input-data/) - static data provided as input
* [`raw-data`](raw-data/) - intermediate files used for generating output
* [`output-data`](output-data/) - final output files for use
* [`queries/construction`](queries/construction/) - SQL and SPARQL queries used for processing data. Filenames generally reflect the output filename.

## Building

[`run.sh`](run.sh) runs queries to build all data in raw and output data

### Requirements

* Python 3.10+ (see [requirements.txt](../requirements.txt)), Java 1.11, Node.js 22+, UNIX environment
