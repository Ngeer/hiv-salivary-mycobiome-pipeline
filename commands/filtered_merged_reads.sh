#!/bin/bash
mkdir -p /mnt/d/FUNGAL/filtered_reads
docker run --rm \
  -v /mnt/d/FUNGAL/merged_reads:/data/input \
  -v /mnt/d/FUNGAL/filtered_reads:/data/output \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  bash -c '
    for f in /data/input/*_merged.fastq; do
      base=$(basename "$f" _merged.fastq)
      vsearch --fastq_filter /data/input/${base}_merged.fastq \
        --fastq_maxee 1.0 \
        --fastaout /data/output/${base}_filtered.fasta \
        --relabel ${base}_ \
        2> /data/output/${base}_filter_log.txt
    done'
