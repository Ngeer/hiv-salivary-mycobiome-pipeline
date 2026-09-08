docker run --rm \
  -v /mnt/d/FUNGAL/derep_reads:/data \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  vsearch --cluster_unoise /data/all_samples_derep.fasta \
    --minsize 8 \
    --centroids /data/zotus_raw.fasta \
    2> /mnt/d/FUNGAL/derep_reads/unoise_log.txt
