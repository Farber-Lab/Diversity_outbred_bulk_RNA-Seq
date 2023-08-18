# Diversity Outbred (DO) bulk RNA-Seq pipeline

## Getting started

Clone this repository in your computing environment

```bash
#!/usr/bin/bash
# make sure git is set up to handle SSH login, alternatively use HTTPS
git clone git@github.com:Sktbanerjee1/Diversity_outbred_bulk_RNA-Seq.git
```

## Workflow for the RNA-Seq Analysis

### QC of the FASTQ files

assumed execution from the project folder path `.../Diversity_outbred_bulk_RNA-Seq/`

Run FATQC on local computing environment

```bash
#!/bin/bash
# make sure FASTQC is installed and availble in the path
bash src/sh/run_fastqc.sh --help
```
Usage: src/sh/run_fastqc.sh -i target_dir -o out_dir -m run_mode
    -i path to directory with fastq files
    -o Path to the directory where the outputs will be written
    -m value should be one of Trimmed/Untrimmed 

Run FASTQC on Rivanna (UVA internal)   
```bash
#!/bin/bash
# running with slurm (UVA internal)
sbatch src/slurm/run_fastqc.slurm
```
In this case the `.slurm` script needs to be edited. The user should change the values of  `target_dir`, `out_dir`, and `run_mode` in the slurm script.
