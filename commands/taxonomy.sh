docker run --rm \
  -v /mnt/d/FUNGAL/derep_reads:/data/derep \
  -v /mnt/d/FUNGAL/unite_db:/data/unite \
  quay.io/biocontainers/vsearch:2.28.1--h6a68c12_0 \
  vsearch --sintax /data/derep/zotus.fasta \
    --db /data/unite/sh_general_release_dynamic_19.02.2025_sintax.fasta \
    --tabbedout /data/derep/zotu_taxonomy_v2.tsv \
    --sintax_cutoff 0.8
