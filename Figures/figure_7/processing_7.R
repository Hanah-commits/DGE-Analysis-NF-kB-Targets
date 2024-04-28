
library(dplyr)
library(tidyr)
library(pheatmap)

# STEP 1: Check how many rela genes are in treated

# get RELA-associated genes
BL <- scan("datapoints/bl_negvspos/target_de_genes.txt", what = "")
dark <- scan("datapoints/dark_negvspos/target_de_genes.txt", what = "")
RELA <- unique(intersect(BL, dark))


# get RELA-associated genes in treated
treated <- read.table("datapoints/treated/sleuth_treated_gene_WT.tsv", header=TRUE, sep='\t')
treated_genes <- scan("datapoints/treated/target_de_genes.txt", what = "")
treated <- treated[treated$target_id %in% treated_genes, ]

## add rela genes found in BL + Treated, Dark + Treated
treated_BL = setdiff(intersect(treated_genes, BL), RELA)
treated_Dark = setdiff(intersect(treated_genes, dark), RELA)
RELA = c( RELA, treated_BL, treated_Dark)

## get de-RELA genes from treated
rela = treated[treated$target_id %in% RELA, ]
rela_de_genes = rela$target_id

### read sleuth objects to get tpms

####### pos
pos_so = readRDS("datapoints/sleuth/pos.rds")

# get tpm
pos_tpm= pos_so$obs_norm[, c("sample", "target_id", "tpm")]

## get mean tpm for BL and D conditions
pos_tpm <- as.data.frame(
  pos_tpm %>%
  mutate(sample = ifelse(grepl("^BL", sample), "BL", "D")) %>%
  group_by(sample, target_id) %>%
  summarize(tpm = mean(tpm)))

# get tpm of rela_de_genes
pos_tpm = pos_tpm[pos_tpm$target_id %in% rela_de_genes, ]

###### neg
neg_so = readRDS("datapoints/sleuth/neg.rds")

# get tpm
neg_tpm= neg_so$obs_norm[, c("sample", "target_id", "tpm")]

## get mean tpm for BL and D conditions
neg_tpm <- as.data.frame(
  neg_tpm %>%
  mutate(sample = ifelse(grepl("^BL", sample), "BL", "D")) %>%
  group_by(sample, target_id) %>%
  summarize(tpm = mean(tpm)))

# get tpm of rela_de_genes
neg_tpm = neg_tpm[neg_tpm$target_id %in% rela_de_genes, ]

### treated
treated_so = readRDS("datapoints/sleuth/treated.rds")

# get tpm
treated_tpm= treated_so$obs_norm[, c("sample", "target_id", "tpm")]

## get mean tpm for BL and D conditions
treated_tpm <- as.data.frame(
  treated_tpm %>%
  mutate(sample = ifelse(grepl("^BL", sample), "BL", "D")) %>%
  group_by(sample, target_id) %>%
  summarize(tpm = mean(tpm)))

# get tpm of rela_de_genes
treated_tpm = treated_tpm[treated_tpm$target_id %in% rela_de_genes, ]

combined_df <- bind_rows(
  neg_tpm %>% rename(neg_control_tpm = tpm),
  pos_tpm %>% rename(pos_control_tpm = tpm),
  treated_tpm %>% rename(treated_tpm = tpm)
)
combined_df <- as.data.frame(
  combined_df %>%
  group_by(sample, target_id) %>%
  summarise_all(~ifelse(all(is.na(.)), NA, max(., na.rm = TRUE))))

# rename columns
colnames(combined_df) <- c("sample", "target_id", "Negative Control", "Positive Control", "Treated")

# log2 transform tpm values
tpm_cols = c("Negative Control", "Positive Control", "Treated")
combined_df[tpm_cols] = log2(combined_df[tpm_cols] + 1)

# Pivot the DataFrame to have sample as columns and target_id as rows
df_pivot <- pivot_wider(combined_df, id_cols = target_id, names_from = sample, values_from = c("Negative Control", "Positive Control", "Treated"))
# Reorder columns
df_pivot <- df_pivot[, c("target_id", "Negative Control_D", "Negative Control_BL", "Positive Control_D", "Positive Control_BL", "Treated_D", "Treated_BL")]

# Extract relevant columns for heatmap
heatmap_data <- df_pivot[, !names(df_pivot) %in% c("target_id")] # remove target_id column
rownames(heatmap_data) <- df_pivot$target_id

# Create a heatmap of mean normalised expression values
pheatmap(
  heatmap_data,  
  cluster_cols = FALSE,  # Disable clustering of columns
  cluster_rows = FALSE,  # Disable clustering of rows
  fontsize_col = 8,  # Adjust font size for column labels
  fontsize_row = 10,  # Adjust font size for row labels
  main = "Mean TPM of RELA-associated Genes (log2-transformed)",
  angle_col = 45,  # Rotate the x-axis labels by 90 degrees,
  color = hcl.colors(50, "viridis"),
  width = 50,  # Set the width to 10 inches
  height = 8,   # Set the height to 8 inches
  cellwidth = 75
)
