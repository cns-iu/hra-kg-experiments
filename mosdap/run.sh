#!/bin/bash
set -ev
PATH=../bin:$PATH

LOD=https://lod.humanatlas.io/sparql

if [ "$1" == "--clean" ]; then
  rm output-data/*.csv
fi

# TODO