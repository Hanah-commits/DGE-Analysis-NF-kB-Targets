#!/bin/bash

# Define the input TSV files
tsv1=$1  #tx2gene_id.tsv
tsv2=$2  # gencodeid_name.tsv

# Edit the gene_id column to keep only values before the dot
awk -F'\t' -v OFS='\t' 'NR == 1 { print $1, $2; next } { sub(/\..*$/, "", $2); print $1, $2 }' "$tsv1" > edited_"$tsv1"

# Sort the edited TSV file based on the first field (gene ID)
sort -t$'\t' -k2,2 edited_"$tsv1" -o sorted_"$tsv1"
sort -t$'\t' -k1,1 "$tsv2" -o sorted_"$tsv2"


# Join the two TSV files based on the common gene_id and gene stable ID
# Output is a temporary TSV file
join -t$'\t' -1 2 -2 1 sorted_"$tsv1" sorted_"$tsv2" > tmp.tsv

# Create the final output TSV file
awk -F'\t' 'BEGIN {OFS="\t"} { print $2, $3 }' tmp.tsv > tx2gene_name.tsv

# Clean up the temporary file
rm tmp.tsv sorted_* edited_"$tsv1"

