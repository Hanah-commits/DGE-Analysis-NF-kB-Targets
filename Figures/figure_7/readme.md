# Heatmap 

## Input files

- bl_negvspos/target_de_genes.txt : List of genes deregulated by eGFP-RelA (under Blue Light)
- dark_negvspos/target_de_genes.txt : List of genes deregulated by eGFP-RelA (under Darkness)
- treated/target_de_genes.txt : List of genes deregulated by the condensate condition
- sleuth/neg.rds :TPM scores of the genes deregulated in the empty vector on blue light exposure.
- sleuth/pos.rds :TPM scores of the genes deregulated by eGFP-RelA on blue light exposure.
- sleuth/treated.rds : TPM scores of the genes deregulated by the condensate condition.

## Scripts

- processing_7.R : To make a heatmap showing the log2-transformed, mean transcripts expression levels of the direct targets of eGFP-RelA.

### Usage:

```
$ Rscript processing_7.R
```