#!/bin/bash

# Define the path to the text file containing file paths
input_file="2_3_fastq_paths.txt"

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

# create direcotry for adapter filtering if it doesn't exist
mkdir -p adapter_trimmed

# Print the values in the array
for sample in "${samples[@]}"; do
    echo "$sample"
    
    # Create an output file for each sample    
    output_file_1="${sample}_1.fq.gz"
    output_file_2="${sample}_2.fq.gz"

    # Get the file names being trimmed
    input_file_1="$(< "$input_file" grep -E "/${sample}_1.fq.gz")"
    input_file_2="$(< "$input_file" grep -E "/${sample}_2.fq.gz")"

    # Print the names of files being trimmed
    echo "Trimming files for $sample:"
    
     reformat.sh in1="$input_file_1" in2="$input_file_2" out1="$output_file_1" out2="$output_file_2" minlength=50

done
