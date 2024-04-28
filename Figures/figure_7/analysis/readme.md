# Workflow:

### Preprocessing: 

- 1_merge_lanes.sh : The reads from the strand-specific sequencing replicates were pooled together. This was done to improve the accuracy and depth of coverage. After this, samples had two FASTQ files each – one for each strand.

- 2_1_adapter_trim.sh : Cutadapt was used for adapter trimming.

- 2_2_quality_trim.sh : Quality trimming was done using Q=30 as a threshold to filter out low-quality bases using bbduk.sh from the BBMap suite.

- 2_3_length_trim.sh : Length filtering was done using reformat.sh (BBMap) to filter out reads shorter than 50 bp.

### Quantification:

- 3_quantify.sh : Transcript quantification was done using Kallisto. The reference transcriptome was obtained from GENCODE (Release 38).

### Transcript-to-Gene Mapping:

- 4_tx2gene.R : To map each gene to its constituent transcripts.

- 5_get_genename.sh : Replace gene ids with gene names.

- 6_check_all_transcripts.sh : Check if absent genes (w/o gene name - geneid matching) and add them to final transcript-gene mapping file

### Analysis:

- processing_9.1.R : Differential gene expression anlysis between darkness and blue light (empty vector) to get the TPM scores of the deregulated genes => sleuth/neg.rds
  
- processing_9.2.R : Differential gene expression anlysis between darkness and blue light (eGFP-RelA) to get the TPM scores of the deregulated genes => sleuth/pos.rds
  
- processing_9.3.R : Differential gene expression anlysis between darkness and blue light (eGFP-RelA + Cry2olig-mCh-FUSN-NLS-NbGFP + Cry2olig-mCh-FUSN-NLS) to get:
    -- the list of genes deregulated by the condensate => treated/target_de_genes.txt, treated/sleuth_treated_gene_WT.tsv
    -- TPM scores of the deregulated genes => sleuth/treated.rds
    
- processing_10.1.R : Differential gene expression anlysis between empty vector and eGFP-RelA (darkness) to get the list of genes deregulated by eGFP-RelA  => dark_negvspos/target_de_genes.txt

- processing_10.2.R : Differential gene expression anlysis between empty vector and eGFP-RelA (blue light) to get the list of genes deregulated by eGFP-RelA => bl_negvspos/target_de_genes.txt
    
- processing_7.R: 