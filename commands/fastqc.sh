#!/bin/bash

mkdir -p /mnt/d/FUNGAL/fastqc_raw
docker run --rm \
  -v /mnt/d/FUNGAL/raw_reads:/data/input \
  -v /mnt/d/FUNGAL/fastqc_raw:/data/output \
  staphb/fastqc bash -c 'fastqc /data/input/*.fastq.gz -o /data/output'
