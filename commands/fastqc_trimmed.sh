#!/bin/bash

mkdir -p /mnt/d/FUNGAL/trimmed_fastqc
docker run --rm \
  -v /mnt/d/FUNGAL/trimmed_reads:/data/input \
  -v /mnt/d/FUNGAL/trimmed_fastqc:/data/output \
  staphb/fastqc bash -c 'fastqc /data/input/*.fastq.gz -o /data/output'
