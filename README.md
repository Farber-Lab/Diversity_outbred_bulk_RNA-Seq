# Diversity Outbred (DO) bulk RNA-Seq pipeline

## Getting started

Clone this repository in your computing environment

```bash
#!/usr/bin/bash
# make sure git is set up to handle SSH login, alternatively use HTTPS
git clone git@github.com:Sktbanerjee1/Diversity_outbred_bulk_RNA-Seq.git
cd Diversity_outbred_bulk_RNA-Seq/
```

## Workflow for the RNA-Seq Analysis

The following scripts are assumed to be executed from the project folder path `.../Diversity_outbred_bulk_RNA-Seq/`

### QC of the FASTQ files

This step is to be performed twice, once on the raw fastq files (before trimming) and once after trimming.

* Run FATQC on local computing environment

```bash
#!/bin/bash
# make sure FASTQC is installed and availble in the path
bash src/sh/run_fastqc.sh --help


Usage: 
src/sh/run_fastqc.sh -i target_dir -o out_dir -m run_mode
    -i path to directory with fastq files
    -o Path to the directory where the outputs will be written
    -m value should be one of Trimmed/Untrimmed
```

* Run FASTQC as a slurm job (UVA internal on Rivanna)

```bash
#!/bin/bash
sbatch src/slurm/run_fastqc.slurm
```
If needed, the user should change the values of  `target_dir`, `out_dir`, and `run_mode` in the slurm script.

### Combine FASTQC results with MultiQC

* Run MultiQC on local computing environment

```bash
#!/bin/bash
# make sure multiqc is installed and availble in the path
bash src/sh/run_multiqc.sh --help

Usage: 
src/sh/run_multiqc.sh -i target_dir -o out_dir
    -i path to directory with FASTQC outputs
    -o Path to the directory where the multiQC report will be written
```
    
* Run MultiQC as a slurm job (UVA internal on Rivanna)

```bash
#!/bin/bash
sbatch src/slurm/run_multiqc.slurm
```
If needed, the user should change the values of  `target_dir`, and `out_dir`in the slurm script.

### Drop low quality reads and adapter sequences

Make sure to identify the sequencing platform and the library preparation protocol. Generally, the sequencing protocol utilizes the TruSeq Stranded mRNA kit, supported accross a number of Illumina platform. This information helps us to identify appropiate adapters that must be trimmed. To run this step, a set of adapter sequences needs to be provided as a `.fasta` file, and a list of standard TruSeq adapters are provided as `Illumina_TruSeq_adapters.fasta`. 

