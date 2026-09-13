# Salivary Mycobiome in HIV Infection — Result Figures

Replication of: Chang S, Guo H, Li J, Ji Y, Jiang H, Ruan L, Du M (2021).
*Comparative Analysis of Salivary Mycobiome Diversity in Human Immunodeficiency
Virus-Infected Patients.* Front. Cell. Infect. Microbiol. 11:781246.
doi: 10.3389/fcimb.2021.781246

## Aim

To replicate the original study's characterization of the salivary mycobiome
in HIV-infected individuals, HIV-uninfected controls, and HIV-infected
individuals after 6 months of antiretroviral therapy (ART), using the same
public raw sequencing data and an independently built Nextflow/zOTU pipeline.
The goal is to reproduce the diversity, composition, and classification
patterns reported in the original paper as a pipeline validation exercise.

## Project / Accession

- **BioProject:** PRJNA626395 (NCBI SRA)
- **Marker gene:** Internal Transcribed Spacer (ITS) region, fungal rRNA
- **Original sample size:** 84 non-stimulated saliva samples (30 HIV+, 30
  Control, 24 followed up after 6 months ART)
- **Groups:** `HIV`, `Control`, `ART`

## Samples

Saliva samples were collected from HIV-infected patients (newly diagnosed,
ART-naive) and age/gender-matched HIV-uninfected controls, with a subset of
HIV-infected patients re-sampled after 6 months of ART. Raw paired-end FASTQ
reads were pulled directly from SRA under PRJNA626395.

## Methodology

The pipeline mirrors the original paper's processing steps:

1. **Quality control** — `fastp` / `fastqc` for read quality assessment and
   trimming (`fastp.sh`, `fastqc.sh`, `fastqc_trimmed.sh`)
2. **Aggregated QC reporting** — `multiqc` across raw and trimmed reads
   (`multiqc.sh`, `multiqc2.sh`)
3. **Read merging** — paired-end read merging (`merged.sh`)
4. **Quality filtering of merged reads** (`filtered_merged_reads.sh`)
5. **Dereplication** — removal of duplicate sequences prior to clustering
   (`dereplicate.sh`)
6. **zOTU clustering** — UNOISE3 algorithm (zero-radius OTUs), chimera
   removal, and taxonomic assignment against the UNITE reference database
7. **Statistical analysis** — alpha diversity (observed richness, Chao1,
   Shannon), beta diversity (Bray-Curtis, PCoA), rank-abundance, core
   mycobiome prevalence, co-occurrence network, genus-level heatmap
   clustering, and phylum-level composition, performed in R

Scripts for each step are versioned individually in the `commands/` folder
of this repository, with per-file commit messages documenting purpose.

## Results

| Figure | File | Description |
|---|---|---|
| Rarefaction curves | `rarefaction_curves.png` | Species accumulation per sample as sequencing depth increases, colored by group (HIV = green, Control = red, ART = black); most samples approach saturation, supporting adequate sequencing depth |
| Observed richness | `observed_richness.png` | Boxplot of observed zOTU richness by group; HIV group shows visibly higher median richness and wider spread than Control and ART |
| Rank-abundance curve | `rank_abundance_curve.png` | Genus-level total abundance ranked from most to least abundant on a log scale, showing a typical long-tailed community structure dominated by a small number of highly abundant genera |
| PCoA (beta diversity) | `pcoa_beta_diversity.png` | Principal coordinates analysis (Bray-Curtis distance); HIV samples form a distinct cluster separated from the overlapping Control/ART clusters, consistent with a shift in community composition under HIV infection |
| Phylum composition | `phylum_composition.png` | Stacked relative-abundance bar chart per sample, grouped by HIV/Control/ART; Ascomycota and Basidiomycota dominate across all groups, with visible shifts in Mortierellomycota and Rozellomycota abundance in the HIV group |
| Genus abundance heatmap | `genus_heatmap.png` | Log-scaled heatmap of the top 20 genera with hierarchical clustering of samples and taxa; samples cluster partly, but not fully, by group, most clearly for a subset of HIV samples |
| Core mycobiome prevalence | `core_mycobiome.png` | Proportion of samples in which each genus was detected; a small set of genera (e.g. *Fusarium*, *Aspergillus*, *Mortierella*) are present in nearly all samples and form the core mycobiome |
| Co-occurrence network | `cooccurrence_network.png` | Network of significant pairwise genus correlations (blue = positive, red = negative), highlighting *Verticillium*, *Taphrina*, and *Thyrostroma* as highly connected hub genera |

## Discussion

The replicated results are broadly consistent with the direction of the
original findings: the HIV group shows elevated richness/diversity relative
to Control, with a visible separation in community composition on the PCoA
plot. The phylum- and genus-level composition patterns (dominance of
Ascomycota/Basidiomycota, presence of a small stable core mycobiome) also
align with the original study's description of the salivary mycobiome
structure. Some differences from the original paper are expected given
independent reprocessing of raw reads (different zOTU clustering run,
reference database version, and R package versions), and these should be
interpreted as a pipeline replication rather than an exact numerical
reproduction of the published statistics.

## Conclusion

This replication supports the core conclusion of Chang et al. (2021): HIV
infection is associated with a detectable shift in salivary mycobiome
richness and community composition, and this shift is reflected in
independently reprocessed data using a comparable zOTU-based pipeline. The
pipeline built here (documented in `commands/`) can be reused for further
mycobiome analyses on similar ITS amplicon datasets.

## Data Availability

Raw sequencing reads: NCBI SRA, BioProject
[PRJNA626395](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA626395)
