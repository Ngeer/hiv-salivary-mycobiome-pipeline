installed.packages(c("vegan","dplyr","tidyr","ggplot2"))



options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages(c("vegan","dplyr","tidyr","ggplot2"))

options(download.file.method = "wininet")
install.packages(c("vegan", "dplyr", "tidyr", "ggplot2"))

library(vegan)
library(dplyr)
library(tidyr)
library(ggplot2)

setwd("D:/FUNGAL")

otu_table <- read.delim(
  "D:/FUNGAL/derep_reads/zotu_table_v2.tsv",
  check.names = FALSE   # keeps sample names exactly as-is, no dots/X prefixes added
)
names(otu_table)[1] <- "zotu_id"

View(otu_table)

taxonomy_raw <- read.delim("D:/FUNGAL/derep_reads/zotu_taxonomy_v2.tsv",
 header = FALSE, 
 col.names = c("zotu_id", "tax_full", "strand", "tax_confident"))

View(taxonomy_raw)

 taxonomy_raw$zotu_id <- sub(";size=.*", "", taxonomy_raw$zotu_id)

 head(taxonomy_raw$zotu_id, 5)

 otu_table_ids <- otu_table$zotu_id
tax_check <- taxonomy_raw %>% filter(zotu_id %in% otu_table_ids)
cat("zOTUs that matched by ID:", nrow(tax_check), "\n")

library(tidyr)
library(dplyr)

taxonomy_clean <- taxonomy_raw
taxonomy_clean$tax_full <- gsub("\\([0-9.]+\\)", "", taxonomy_clean$tax_full)

taxonomy_split <- taxonomy_clean %>%
  separate(tax_full, 
           into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"), 
           sep = ",", 
           fill = "right",
           extra = "drop")

taxonomy_split <- taxonomy_split %>%
  mutate(across(Kingdom:Species, ~ sub("^[a-z]:", "", .)))

head(taxonomy_split)
taxonomy_split <- taxonomy_split %>% select(-tax_confident)
head(taxonomy_split)
sample_names <- colnames(otu_table)[-1]  # exclude the zotu_id column
sample_names



library(stringr)

sample_metadata <- data.frame(
  sample_id = sample_names,
  group = case_when(
    str_starts(sample_names, "art_") ~ "ART",
    str_starts(sample_names, "ctrl_") ~ "Control",
    str_starts(sample_names, "hiv_") ~ "HIV",
    TRUE ~ "Unknown"
  )
)

table(sample_metadata$group)
head(sample_metadata)


# --- Prepare the abundance matrix (samples must be columns, ZOTU IDs as rownames) ---
otu_mat <- as.matrix(otu_table[,-1])  # drop the zotu_id column, keep only numbers
rownames(otu_mat) <- otu_table$zotu_id

# --- Prepare the taxonomy matrix (ZOTU IDs as rownames) ---
tax_mat <- as.matrix(taxonomy_split[, c("Kingdom","Phylum","Class","Order","Family","Genus","Species")])
rownames(tax_mat) <- taxonomy_split$zotu_id

# --- Prepare the sample metadata (sample IDs as rownames) ---
sample_df <- sample_metadata
rownames(sample_df) <- sample_df$sample_id

# --- Build the three phyloseq components ---
OTU <- otu_table(otu_mat, taxa_are_rows = TRUE)
TAX <- tax_table(tax_mat)
SAMPLES <- sample_data(sample_df)

# --- Combine into one phyloseq object ---
ps <- phyloseq(OTU, TAX, SAMPLES)

# --- Check it worked ---
ps




library(ggplot2)

# Collapse to phylum level and convert to relative abundance
ps_phylum <- tax_glom(ps, taxrank = "Phylum")
ps_phylum_rel <- transform_sample_counts(ps_phylum, function(x) x / sum(x))

# Convert to a data frame ggplot can use
phylum_df <- psmelt(ps_phylum_rel)

ggplot(phylum_df, aes(x = Sample, y = Abundance, fill = Phylum)) +
  geom_bar(stat = "identity") +
  facet_wrap(~group, scales = "free_x") +
  theme_minimal() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(title = "Fungal Phylum Composition by Group", y = "Relative Abundance", x = "Sample")


ggplot(phylum_df, aes(x = Sample, y = Abundance, fill = Phylum)) +
  geom_bar(stat = "identity") +
  facet_wrap(~group, scales = "free_x") +
  theme_minimal() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(title = "Fungal Phylum Composition by Group", 
  y = "Relative Abundance", x = "Sample")


p <- ggplot(phylum_df, aes(x = Sample, y = Abundance, fill = Phylum)) +
  geom_bar(stat = "identity") +
  facet_wrap(~group, scales = "free_x") +
  theme_minimal() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(title = "Fungal Phylum Composition by Group", y = "Relative Abundance", x = "Sample")

print(p)

dim(phylum_df)
head(phylum_df)


ggsave(
  filename = "D:/FUNGAL/phylum_composition.png",
  plot = p,
  width = 10,
  height = 6,
  dpi = 300
)


library(ggplot2)

# Calculate diversity metrics
alpha_div <- estimate_richness(ps, measures = c("Observed", "Shannon"))
alpha_div$sample_id <- rownames(alpha_div)

# Merge with group info
alpha_div <- merge(alpha_div, sample_metadata, by = "sample_id")

# --- Shannon diversity boxplot ---
p_shannon <- ggplot(alpha_div, aes(x = group, y = Shannon, fill = group)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Shannon Diversity by Group", x = "Group", y = "Shannon Index")

ggsave("D:/FUNGAL/shannon_diversity.png", plot = p_shannon, width = 8, height = 6, dpi = 300)

# --- Observed richness boxplot ---
p_richness <- ggplot(alpha_div, aes(x = group, y = Observed, fill = group)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Observed ZOTU Richness by Group", x = "Group", y = "Observed ZOTUs")

ggsave("D:/FUNGAL/observed_richness.png", plot = p_richness, width = 8, height = 6, dpi = 300)

# --- Statistical test: is the difference between groups significant? ---
kruskal.test(Shannon ~ groups, data = alpha_div)
kruskal.test(Observed ~ groups, data = alpha_div)


pairwise.wilcox.test(alpha_div$Shannon, alpha_div$group, p.adjust.method = "BH")
pairwise.wilcox.test(alpha_div$Observed, alpha_div$group, p.adjust.method = "BH")


# ===================================================================
# SETUP — install once if needed
# install.packages(c("vegan", "igraph", "pheatmap"))
# ===================================================================
library(phyloseq)
library(ggplot2)
library(dplyr)
library(vegan)
library(igraph)
library(pheatmap)

out_dir <- "D:/FUNGAL/"

# ===================================================================
# 3. RAREFACTION CURVES
# Shows whether sequencing depth was sufficient to capture true diversity
# ===================================================================
otu_mat_t <- t(as(otu_table(ps), "matrix"))  # vegan wants samples as rows



otu_mat_t <- t(as(otu_table(ps), "matrix"))

# Match each sample to its group, in the correct order
group_colors <- as.factor(sample_metadata$group)[match(rownames(otu_mat_t), sample_metadata$sample_id)]

png(paste0(out_dir, "rarefaction_curves_labeled.png"), width = 2400, height = 1600, res = 300)

rarecurve(otu_mat_t, step = 500, label = FALSE, 
          col = group_colors,
          main = "Rarefaction Curves by Sample")

legend("bottomright", 
       legend = levels(as.factor(sample_metadata$group)), 
       col = 1:length(levels(as.factor(sample_metadata$group))), 
       lty = 1, lwd = 2,
       title = "Group")

dev.off()



# ===================================================================
# 4. BETA DIVERSITY / PCoA (Bray-Curtis)
# Shows whether groups cluster separately in ordination space
# ===================================================================
ps_rel <- transform_sample_counts(ps, function(x) x / sum(x))
bray_dist <- phyloseq::distance(ps_rel, method = "bray")
pcoa_ord <- ordinate(ps_rel, method = "PCoA", distance = bray_dist)

p_pcoa <- plot_ordination(ps_rel, pcoa_ord, color = "group") +
  geom_point(size = 3) +
  stat_ellipse(level = 0.8) +
  theme_minimal() +
  labs(title = "PCoA of Salivary Mycobiome (Bray-Curtis)")

ggsave(paste0(out_dir, "pcoa_beta_diversity.png"), plot = p_pcoa, width = 8, height = 6, dpi = 300)

# Statistical test: are groups significantly different in composition?
adonis_result <- adonis2(bray_dist ~ group, data = sample_metadata[match(sample_names(ps), sample_metadata$sample_id),])
print(adonis_result)

# ===================================================================
# 5. CORE VS ACCESSORY MYCOBIOME
# Which genera appear in almost every sample vs. rarely
# ===================================================================
ps_genus <- tax_glom(ps, taxrank = "Genus")
genus_presence <- apply(as(otu_table(ps_genus), "matrix") > 0, 1, sum)
genus_prevalence <- data.frame(
  Genus = tax_table(ps_genus)[,"Genus"],
  Prevalence = genus_presence / nsamples(ps_genus)
)
genus_prevalence <- genus_prevalence %>% arrange(desc(Prevalence)) %>% head(30)



p_core <- ggplot(genus_prevalence, aes(x = reorder(Genus, Prevalence), y = Prevalence)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  geom_hline(yintercept = 0.8, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Core Mycobiome: Genus Prevalence Across Samples", 
       x = "Genus", y = "Proportion of Samples Present")

ggsave(paste0(out_dir, "core_mycobiome.png"), plot = p_core, width = 8, height = 8, dpi = 300)

# ===================================================================
# 6. RANK-ABUNDANCE (WHITTAKER) CURVE
# How dominant is the top genus vs everything else, on a log scale
# ===================================================================
genus_totals <- taxa_sums(ps_genus)
genus_names <- as.character(tax_table(ps_genus)[,"Genus"])
rank_df <- data.frame(Genus = genus_names, Total = genus_totals) %>%
  arrange(desc(Total)) %>%
  mutate(Rank = row_number())

p_rank <- ggplot(rank_df, aes(x = Rank, y = Total)) +
  geom_line() + geom_point() +
  scale_y_log10() +
  theme_minimal() +
  labs(title = "Rank-Abundance Curve (Genus Level)", 
       x = "Genus Rank", y = "Total Abundance (log scale)")

ggsave(paste0(out_dir, "rank_abundance_curve.png"), plot = p_rank, width = 8, height = 6, dpi = 300)

# ===================================================================
# 7. CO-OCCURRENCE NETWORK
# Which genera tend to appear together (simple correlation-based)
# ===================================================================
genus_mat <- as(otu_table(tax_glom(ps_rel, taxrank = "Genus")), "matrix")
rownames(genus_mat) <- as.character(tax_table(tax_glom(ps_rel, taxrank = "Genus"))[,"Genus"])

top_genera <- names(sort(rowSums(genus_mat), decreasing = TRUE))[1:25]
genus_mat_top <- genus_mat[top_genera, ]

cor_mat <- cor(t(genus_mat_top), method = "spearman")
cor_mat[abs(cor_mat) < 0.4] <- 0  # keep only meaningfully strong correlations
diag(cor_mat) <- 0

net <- graph_from_adjacency_matrix(cor_mat, weighted = TRUE, mode = "undirected")
net <- delete.vertices(net, degree(net) == 0)  # drop unconnected genera

png(paste0(out_dir, "cooccurrence_network.png"), width = 2400, height = 2400, res = 300)
plot(net, 
     vertex.size = 8, 
     vertex.label.cex = 0.7,
     edge.width = abs(E(net)$weight) * 3,
     edge.color = ifelse(E(net)$weight > 0, "steelblue", "firebrick"),
     main = "Fungal Genus Co-occurrence Network")
dev.off()

# ===================================================================
# 8. GENUS-LEVEL HEATMAP (clustered)
# ===================================================================
top20_genera <- names(sort(rowSums(genus_mat), decreasing = TRUE))[1:20]
heatmap_mat <- genus_mat[top20_genera, ]

annotation_col <- data.frame(Group = sample_metadata$group)
rownames(annotation_col) <- sample_metadata$sample_id
annotation_col <- annotation_col[colnames(heatmap_mat), , drop = FALSE]

png(paste0(out_dir, "genus_heatmap.png"), width = 3000, height = 2000, res = 300)
pheatmap(log1p(heatmap_mat), 
         annotation_col = annotation_col,
         show_colnames = FALSE,
         main = "Top 20 Genera Abundance Heatmap (log-scaled)")
dev.off()

cat("All graphs saved to", out_dir, "\n")