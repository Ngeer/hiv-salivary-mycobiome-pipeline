#!/bin/bash
mkdir -p /mnt/d/FUNGAL/derep_reads_v2
docker run --rm \
  -v /mnt/d/FUNGAL/filtered_reads:/data/input \
  -v /mnt/d/FUNGAL/derep_reads_v2:/data/output \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  bash -c '
    for f in /data/input/*_filtered.fasta; do
      base=$(basename "$f" _filtered.fasta)
      vsearch --derep_fulllength /data/input/${base}_filtered.fasta \
        --relabel ${base}. \
        --sizeout \
        --fasta_width 0 \
        --output /data/output/${base}_derep.fasta \
        2> /data/output/${base}_derep_log.txt
    done'
