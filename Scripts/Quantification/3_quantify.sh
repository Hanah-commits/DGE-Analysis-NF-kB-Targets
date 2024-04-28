#!/bin/bash

# build index of your reference transcriptome
kallisto index -i  ref.index gencode.v38.transcripts.fa

# Define the path to the text file containing file paths
input_file="3_fastq_paths.txt"

# Initialize an empty array to store the extracted values
samples=()

# Read file paths from the text file and extract values
while IFS= read -r path; do
    # Use 'basename' to get the filename without the directory path
    filename=$(basename "$path")

    # Use 'cut' to extract the value before the first underscore
    value=$(echo "$filename" | cut -d '_' -f 1)

    # Add the extracted value to the 'values' array
    samples+=("$value")
done < "$input_file"

processed=()

# Print the values in the array
for sample in "${samples[@]}"; do

   # skip if sample has already been processed
    if [[ " ${processed[*]} " =~ " $sample " ]]; then
        continue
    fi
    
    # Create output directory
    mkdir -p "$sample"
    
    # Get the file names being trimmed
    input_file_1="$(< "$input_file" grep -E "/${sample}_1.fq.gz")"
    input_file_2="$(< "$input_file" grep -E "/${sample}_2.fq.gz")"

    # Print the names of files being trimmed
    echo "Quantifying transcript reads for $sample:"
    
    kallisto quant -i ref.index -o "$sample" -b 100 -t 8 "$input_file_1" "$input_file_2"

    # Add sample to "processed" array
    processed+=("$sample")

done
