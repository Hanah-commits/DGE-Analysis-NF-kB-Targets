library(GenomicFeatures)

args<-commandArgs(TRUE)

txdb <- makeTxDbFromGFF(args[1], format = "gff3")
k <- keys(txdb, keytype = "TXNAME")
tx2gene <- select(txdb, k, "GENEID", "TXNAME")

## Remove dupliacte transcript ids
#ENST00000331035.10      ENSG00000185291.12
#ENST00000331035.10      ENSG00000185291.12_PAR_Y
tx2gene <- tx2gene[!duplicated(tx2gene$TXNAME), ]

write.table(tx2gene, "tx2gene_id.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
