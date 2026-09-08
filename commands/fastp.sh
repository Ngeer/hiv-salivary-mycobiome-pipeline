#!/bin/bash

mkdir -p /mnt/d/FUNGAL/trimmed_reads
docker run --rm \
  -v /mnt/d/FUNGAL/raw_reads:/data/input \
  -v /mnt/d/FUNGAL/trimmed_reads:/data/output \
  quay.io/biocontainers/fastp:0.23.4--h5f740d0_0 \
  bash -c '
    for f in /data/input/*_R1.fastq.gz; do
      base=$(basename "$f" _R1.fastq.gz)
      fastp \
        -i /data/input/${base}_R1.fastq.gz \
        -I /data/input/${base}_R2.fastq.gz \
        -o /data/output/${base}_1_trimmed.fastq.gz \
        -O /data/output/${base}_2_trimmed.fastq.gz \
        --detect_adapter_for_pe \
        --trim_front1 29 \
        --trim_front2 23 \
        --length_required 30 \
        --qualified_quality_phred 30 \
        --average_qual 30 \
        --json /data/output/${base}_fastp.json \
        --html /data/output/${base}_fastp.html
    done'
