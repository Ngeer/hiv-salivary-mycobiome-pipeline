docker run --rm \
  -v /mnt/d/FUNGAL/derep_reads:/data \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  vsearch --uchime3_denovo /data/zotus_raw.fasta \
    --nonchimeras /data/zotus.fasta \
    --chimeras /data/zotus_chimeras.fasta \
    2> /mnt/d/FUNGAL/derep_reads/uchime_log.txt
