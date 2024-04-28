library(dplyr)
library(sleuth)
library(ggplot2)
library(ggrepel)

## transcript-gene mapping
tx2gene <- read.table("tx2gene.tsv", col.names=c("target_id", "gene_id"), skip=1, header=FALSE, sep='\t')

## specify experimental design and the relationships between samples, conditions, and replicates
sample_data <- data.frame(
  sample = c("BL1b","BL2b", "BL3b","D1a","D2a","D3a"),
  condition = c("Illumination_negative_control", "Illumination_negative_control", "Illumination_negative_control", "Darkness_negative_control", "Darkness_negative_control", "Darkness_negative_control"),
  replicate = c(1, 2, 3, 1, 2, 3),
  path = c(
    "Quantification/output/BL1b/abundance.h5", 
    "Quantification/output/Bl2b/abundance.h5", 
    "Quantification/output/BL3b/abundance.h5",
    "Quantification/output/D1a/abundance.h5",
    "Quantification/output/D2a/abundance.h5", 
    "Quantification/output/D3a/abundance.h5"),
  stringsAsFactors = FALSE
)


##  load the kallisto processed data into the object 
sleuth_obj <- sleuth_prep(
  sample_data = sample_data,
  target_mapping = tx2gene,
  sample_to_covariates = sample_data,
  path_to_abundance = sample_data$path,
  extra_bootstrap_summary = TRUE,
  read_bootstrap_tpm = TRUE,
  gene_mode = TRUE,
  aggregation_column = 'gene_id'
)

# estimate parameters for the sleuth response error measurement (full) model
sleuth_obj<- sleuth_fit(sleuth_obj, ~condition, 'full')

sleuth_obj<- sleuth_fit(sleuth_obj, ~1, 'reduced')

# Likelihood ratio test
sleuth_obj <- sleuth_lrt(sleuth_obj, 'reduced', 'full')

# method1: LRT
sleuth_table_LRT <- sleuth_results(sleuth_obj, 'reduced:full', 'lrt', show_all = TRUE)
sleuth_table_LRT <- sleuth_table_LRT[order(sleuth_table_LRT$qval),]

# get de genes
de_genes_LRT <- sleuth_table_LRT$target_id[sleuth_table_LRT$qval < 0.05]

# get target genes
target <- scan("target_genes_all.txt", what = "")

# check which target genes are de genes
target_de_LRT <- unique(intersect(target, de_genes_LRT))

# METHOD2: WT test
sleuth_obj = sleuth_wt(sleuth_obj, 'conditionIllumination_negative_control')

sleuth_table_WT = sleuth_results(sleuth_obj, 'conditionIllumination_negative_control', test_type = 'wt')
sleuth_table_WT <- sleuth_table_WT[order(sleuth_table_WT$qval),]

# get de genes
de_genes_WT <- sleuth_table_WT$target_id[sleuth_table_WT$qval < 0.05]

# check which target genes are de genes
target_de_WT <- unique(intersect(target, de_genes_WT))

# check if lrt and wt find the same genes
target_de_both = unique(intersect(target_de_LRT, target_de_WT))

# volcano plot using wt results

# Create a new column "Gene type"
sleuth_table_WT$`Gene type` <- ifelse(sleuth_table_WT$target_id %in% target_de_both, "DE NF-kB target",
                                      ifelse(sleuth_table_WT$target_id %in% target, "NF-kB target", "Other"))

# Add new column with rank (based on qval)
sleuth_table_WT <- sleuth_table_WT %>%
  group_by(`Gene type`) %>%
  arrange(qval) %>%
  mutate(Rank = row_number())

# assigns a value of 1 if either the Gene type is "DE NF-kB target" or the target_id is "CXCL1"
sleuth_table_WT <- sleuth_table_WT %>%
  mutate(label = ifelse(`Gene type` == "DE NF-kB target" & Rank <= 10 | target_id %in% c("CXCL1", "RELA"), 1, 0))

# Create a volcano plot using WT results and mark target genes
ggplot(sleuth_table_WT, aes(x = b/log(2), y = -log10(qval))) +
  geom_point(data = subset(sleuth_table_WT, `Gene type` == "Other"), aes(color = `Gene type`), alpha = 0.2) +
  geom_point(data = subset(sleuth_table_WT, `Gene type` == "NF-kB target"), aes(color = `Gene type`)) +
  geom_point(data = subset(sleuth_table_WT, `Gene type` == "DE NF-kB target"), aes(color = `Gene type`)) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "red") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "blue") +
  labs(x = "Log2FC", y = "-log10(qvalue)") +
  scale_color_manual(values = c("DE NF-kB target" = "red", "NF-kB target" = "orange", "Other" = "blue")) +
  theme_minimal()+
  ggtitle("empty vector: Darkness vs Blue Light")+
  theme(plot.title = element_text(hjust = 0.5))+
  geom_label_repel(
    data = subset(sleuth_table_WT, `label` == 1),
    aes(label = target_id),
    size = 3,
    box.padding = 1.0,
    max.overlaps = Inf,
    point.padding = 0.3,
    segment.color = "black",
    segment.linetype = 1,
    segment.curvature = 0,
    arrow = arrow(length = unit(0.015, "npc"))
  )
