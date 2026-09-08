docker run --rm \
  -v /mnt/d/FUNGAL/derep_reads_v2:/data/derep2 \
  -v /mnt/d/FUNGAL/derep_reads:/data/derep \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  bash -c '
    cat /data/derep2/*_derep.fasta > /data/derep/all_samples_relabeled.fasta
    vsearch --usearch_global /data/derep/all_samples_relabeled.fasta \
      --db /data/derep/zotus.fasta \
      --id 0.97 \
      --otutabout /data/derep/zotu_table_v2.tsv \
      2> /data/derep/otutab_log_v2.txt
  '
