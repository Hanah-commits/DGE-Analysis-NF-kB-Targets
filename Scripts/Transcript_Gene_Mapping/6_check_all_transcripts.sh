#!/bin/bash

# Define the input TSV files
tsv1=$1 # tx2gene_id.tsv
tsv2=$2 # gencodeid_name.tsv
tsv3=$3 # gencode.gff3 file
tsv4=$4 #tx2gene_name.tsv

# Edit the gene_id column to keep only values before the dot from tx2gene_name
awk -F'\t' -v OFS='\t' 'NR == 1 { print $1, $2; next } { sub(/\..*$/, "", $2); print $2}' "$tsv1" > edited_"$tsv1"

# get gene id from gecodeid_name file
awk -F'\t' '{print $1}' "$tsv2" | sort | uniq > edited_"$tsv2"

## comapre files (find which genes don't have names)
awk -F'\t' 'NR==FNR{a[$1];next} !($1 in a)' edited_"$tsv2" edited_"$tsv1" | sort | uniq > absent_genes.tsv

# Clean up the temporary file
rm edited_*

## check if absent genes in tx2gene_name.tsv file
if [ -s absent_genes.tsv ]; then

	# extract non-truncated gene id from gencode
	zgrep -wFf absent_genes.tsv "$tsv3" | awk '$3 == "gene" {print}' | grep -Po 'gene_id=ENSG[^;]+' | sed -r 's/.*gene_id=(ENSG[^;]+).*/\1/' > gene_ids.txt

	# Extract gene names
	zgrep -wFf gene_ids.txt "$tsv3" | awk '$3 == "gene" {print}' | grep -Po 'gene_name=[^;]+' | sed -r 's/gene_name=//' > gene_names.txt

	# Combine gene IDs and names into a single TSV file
	paste gene_ids.txt gene_names.txt > absent_genes_nameinfo.tsv

	# Concatenate with tx2gene_name.tsv
	cat "$tsv4" absent_genes_nameinfo.tsv > tx2gene.tsv

	# Clean up temporary files
	rm gene_ids.txt gene_names.txt absent_genes_*
fi
