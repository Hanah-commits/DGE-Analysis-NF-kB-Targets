#!/bin/bash

# Define the input file containing file paths
input_file="1_fastq_paths.txt"

# Read the subdirectory names under RawData into an array named "samples"
mapfile -t samples < <(grep -oP '(?<=RawData/)[^/]*' "$input_file" | sort -u)

# Loop through each sample directory
for sample in "${samples[@]}"; do
    # Create an output file for each sample
    output_file="${sample}_1.fq.gz"

    # Get the file names being merged
    input_files_L03="$(< "$input_file" grep -E "/${sample}/.*L03_.*_1.fq.gz")"
    input_files_L04="$(< "$input_file" grep -E "/${sample}/.*L04_.*_1.fq.gz")"

    # Print the names of files being merged
    echo "Merging files for $sample into $output_file:"
    echo "$input_files_L03"
    echo "$input_files_L04"

    # Use 'cat' to concatenate files matching the specified patterns
    cat $input_files_L03 > "$output_file"
    cat $input_files_L04 >> "$output_file"

    echo "Concatenated files for $sample into $output_file"

    output_file="${sample}_2.fq.gz"

    # Get the file names being merged
    input_files_L03="$(< "$input_file" grep -E "/${sample}/.*L03_.*_2.fq.gz")"
    input_files_L04="$(< "$input_file" grep -E "/${sample}/.*L04_.*_2.fq.gz")"

    # Print the names of files being merged
    echo "Merging files for $sample into $output_file:"
    echo "$input_files_L03"
    echo "$input_files_L04"

    # Use 'cat' to concatenate files matching the specified patterns
    cat $input_files_L03 > "$output_file"
    cat $input_files_L04 >> "$output_file"

    echo "Concatenated files for $sample into $output_file"
done
