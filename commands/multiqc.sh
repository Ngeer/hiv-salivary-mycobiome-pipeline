#!/bin/bash



mkdir -p ~/multiqc
docker run --rm --user $(id -u):$(id -g) \
  -v /mnt/d/FUNGAL/fastqc_raw:/data/input \
  -v ~/multiqc:/data/output \
  multiqc/multiqc multiqc /data/input -o /data/output

cp -r ~/multiqc /mnt/d/FUNGAL/multiqc
