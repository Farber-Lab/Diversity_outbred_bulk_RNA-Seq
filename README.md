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

This workflow is designed towards the automated processing of large numbers of samples. Each step below are executed in batch mode.
The following scripts are assumed to be executed from the project folder path `.../Diversity_outbred_bulk_RNA-Seq/`

### QC of the FASTQ files

This step is to be performed twice, once on the raw fastq files (before trimming) and once after trimming.

* Run FASTQC on local computing environment

```bash
#!/bin/bash
# make sure FASTQC is installed and availble in the $PATH
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
# make sure multiqc is installed and availble in the $PATH
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

Make sure to identify the sequencing platform and the library preparation protocol, this information helps us to identify appropiate adapters and contaminents that must be removed. Generally, the sequencing protocol utilizes **TruSeq Stranded mRNA Kit**, supported accross a number of Illumina platform. A set of standard TruSeq adapters are provided as `Illumina_TruSeq_adapters.fasta`. More more details on Illumina adapters visit official documentation. 

* Run Trimmomatic in local computing environment

```bash
#!/bin/bash
# make sure Trimmomatic is installed and availble in the $PATH
bash src/sh/trim_fastq.sh

Usage: 
src/sh/trim_fastq.sh -i target_dir -o out_dir -a adapter_file -w window -m min_len
    -i path to directory with fastq files
    -o Path to the directory where the outputs will be written
    -a Path to the adapter fasta file
    -w Sliding Window
    -m Minimum read length
    -t Trimmomatic alias
```

For default installations of Trimmomatic v0.39, the **trimmomatic alias** shoud be `trimmomatic-0.39.jar` or it can be the path to `trimmomatic-<version>.jar`. For more details on the parameters, see the [Trimmomatic manual](http://www.usadellab.org/cms/?page=trimmomatic).

* Run Trimmomatic as a slurm job (UVA internal on Rivanna)

```bash
#!/bin/bash
sbatch src/slurm/trim_fastq.slurm
```
If needed, the user should change the values of  `target_dir`, `out_dir`, `adapter_file`, `window` and `min_len` in the slurm script.