docker run --rm \
  -v /mnt/d/FUNGAL/derep_reads:/data \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  vsearch --derep_fulllength /data/all_samples_pooled.fasta \
    --sizein --sizeout \
    --output /data/all_samples_derep.fasta \
    --minuniquesize 1
