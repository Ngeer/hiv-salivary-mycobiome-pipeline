#!/bin/bash

mkdir -p ~/multiqc_trimmed_output2_fungi
docker run --rm --user $(id -u):$(id -g) \
  -v /mnt/d/FUNGAL/trimmed_fastqc:/data/input \
  -v ~/multiqc_trimmed_output2_fungi:/data/output \
  multiqc/multiqc multiqc /data/input -o /data/output
