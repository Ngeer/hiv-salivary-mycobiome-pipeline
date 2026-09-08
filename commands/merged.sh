#!/bin/bash
mkdir -p /mnt/d/FUNGAL/merged_reads
docker run --rm \
  -v /mnt/d/FUNGAL/trimmed_reads:/data/input \
  -v /mnt/d/FUNGAL/merged_reads:/data/output \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  bash -c '
    for f in /data/input/*_1_trimmed.fastq.gz; do
      base=$(basename "$f" _1_trimmed.fastq.gz)
      vsearch --fastq_mergepairs /data/input/${base}_1_trimmed.fastq.gz \
        --reverse /data/input/${base}_2_trimmed.fastq.gz \
        --fastqout /data/output/${base}_merged.fastq \
        --fastq_minovlen 10 \
        --fastq_maxdiffs 10 \
        --fastq_allowmergestagger \
       2> /data/output/${base}_merge_log.txt
    done'
