# Pre-processing:

RNA-seq libraries from the 18 samples were sequenced by BGI Tech Solutions on a DNBSEQ platform using paired-end chemistry with a read length of 100 base pairs each. Each strand was sequenced across two separate lanes, generating a total of 4 FASTQ files per sample. 

## Scripts:

The paths to the accompanying input file for each script is given in *_fastq_paths.txt.


- 1_merge_lanes.sh : The reads from the strand-specific sequencing replicates were pooled together. This was done to improve the accuracy and depth of coverage. After this, samples had two FASTQ files each – one for each strand.

- 2_1_adapter_trim.sh : Cutadapt was used for adapter trimming.

- 2_2_quality_trim.sh : Quality trimming was done using Q=30 as a threshold to filter out low-quality bases using bbduk.sh from the BBMap suite.

- 2_3_length_trim.sh : Length filtering was done using reformat.sh (BBMap) to filter out reads shorter than 50 bp.

### Usage: 

```
$ bash <script.sh>
```