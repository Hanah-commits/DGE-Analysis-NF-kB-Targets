# Transcript-to-gene mapping: 

Transcripts need to be associated with gene IDs for gene-level summarization.

## Scripts

- 4_tx2gene.R : To map each gene to its constituent transcripts.

```
# input arguments: 
gencode.v38.gff3

# usage:
$ Rscript 4_tx2gene.R gencode.v38.gff3

# output:
tx2gene_id.tsv
```

- 5_get_genename.sh : Replace gene ids with gene names.

```
# input arguments: 
tx2gene_id.tsv
gencodeid_name.tsv

# usage:
$ bash 5_get_genename.sh tx2gene_id.tsv gencodeid_name.tsv

# output:
tx2gene_name.tsv
```

- 6_check_all_transcripts.sh : Check if absent genes (w/o gene name - geneid matching) and add them to final transcript-gene mapping file

### Usage:

```
# input arguments: 
tx2gene_id.tsv
gencodeid_name.tsv
tx2gene_name.tsv
gencode.v38.gff3

# usage:
$ bash 6_check_all_transcripts.sh tx2gene_id.tsv gencodeid_name.tsv gencode.v38.gff3 tx2gene_name.tsv

# output:
tx2gene_name.tsv
```