# Workflow for the RNA-Seq Analysis

This workflow is designed for automated processing of large numbers of samples. Each step below are executed in batch mode.
The following scripts are to be executed from the project folder path `.../Diversity_outbred_bulk_RNA-Seq/`. 

## 1. QC of the FASTQ files

### 1.1 Run FASTQC

This step is to be performed twice, once on the raw fastq files (before trimming) and once after trimming.

* Run FASTQC on local computing environment

    ```bash
    #!/bin/bash
    # make sure FASTQC is installed and availble in the $PATH
    bash src/sh/run_fastqc.sh --help
    ```
    ```text
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

### 1.2 Combine FASTQC results with MultiQC

* Run MultiQC on local computing environment

    ```bash
    #!/bin/bash
    # make sure multiqc is installed and availble in the $PATH
    bash src/sh/run_multiqc.sh --help
    ```
    ```text
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

### 1.3 Drop low quality reads and adapter sequences

Make sure to identify the sequencing platform and the library preparation protocol, this information helps us to identify appropiate adapters and contaminents that must be removed. Generally, the sequencing protocol utilizes **TruSeq Stranded mRNA Kit**, supported accross a number of Illumina platform. A set of standard TruSeq adapters are provided as `Illumina_TruSeq_adapters.fasta`. More more details on Illumina adapters visit official documentation. 

* Run Trimmomatic in local computing environment

    ```bash
    #!/bin/bash
    # make sure Trimmomatic is installed and availble in the $PATH
    bash src/sh/trim_fastq.sh --help
    ```
    ```text
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

### 1.4 Extract trim statistics from the trimmomatic logs

Trimmomatic provides a number of useful statiscs including the input reads, reads remaining after trimming and dropped reads. However, these statics are part of the console output. 
The following script extracts these statistics from the colsole output saved as a text file or log files.

* Run as a R script

    ```bash
    #!/bin/bash
    # make sure R is installed and Rscript is availble in the $PATH
    Rscript src/R/extract_trimstat.R --help
    ```
    ```text
    Options:
    -e ERROR_LOG, --error_log=ERROR_LOG
            Path to the Trimmomatic error log file

    -c CONSOLE_LOG, --console_log=CONSOLE_LOG
            Path to the Trimmomatic console log file

    -o OUT_DIR, --out_dir=OUT_DIR
            A folder where the output will be written

    -h, --help
            Show this help message and exit
    ```

* Run as a slurm job (UVA internal on Rivanna)

    ```bash
    #!/bin/bash
    sbatch src/slurm/extract_trimstat.slurm
    ```
    Default values for the arguments are set on the R script. The user may set these variables in the slurm script as needed.

## 2. Align RNA-Seq reads

### 2.1 Prepare genome build

We use Hisat2 for the alignment of the raw reads. First step in the alignment is to prepare the necessary files, commonly known as a reference genome build or index. This can be performed by the the following script. This step requires a mouse refernce genome and a list of known SNPs.

```bash
#!/bin/bash
#------- reference genome
# Download mouse reference genome (GRCm38)
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M20/GRCm38.p6.genome.fa.gz

# unzip reference genome
gunzip -d Mus_musculus.GRCm38.dna_sm.toplevel.fa.gz

#------ list of SNPs
# Download list of SNPs from UCSC (GRCm38 mapped positions)
wget http://hgdownload.cse.ucsc.edu/goldenPath/mm10/database/snp142.txt.gz
# unzip the list of SNPs
gunzip -d snp142.txt.gz
```

* Prepare genome build in a local computing environment

    ```bash
    #!/bin/bash
    bash src/sh/prepare_genome_build.sh  --help
    ```
    ```text
    Usage: 
    src/sh/prepare_genome_build.sh -i genome_fasta -s SNP_file -o out_dir -p hisat2_extract_snps_haplotypes_UCSC.py
        -i Path to the reference genome (to be used for the alignment)
        -s Path to the SNP file (to be used for the alignment)
        -p Path to the hisat2_extract_snps_haplotypes_UCSC.py script
        -o Path to the directory where the outputs will be written
    ```

    Note: `hisat2_extract_snps_haplotypes_UCSC.py` is  originally distributed through Hisat2, and has been made available  in this repository at [src/Py/hisat2_extract_snps_haplotypes_UCSC.py](src/Py/hisat2_extract_snps_haplotypes_UCSC.py), under GNU General Public License. The originial script can be found in the [Hisat2 repository](https://github.com/DaehwanKimLab/hisat2/blob/master/hisat2_extract_snps_haplotypes_UCSC.py).


* Prepare genome build through a slurm job (UVA internal on Rivanna)

    ```bash
    #!/bin/bash
    sbatch src/slurm/prepare_genome_build.slurm
    ```
    If needed, the user should chage the values of `genome_fasta`,`snp_file`,`python_script` and `out_dir` in the slurm script.

---

Althernatively, prebilt genome indexes can be downloded from the [Hisat2 downloads](http://daehwankimlab.github.io/hisat2/download/). For this purpose we can use the SNP-aware or SNP and transcript aware genome indexes of the GRCm38 or mm10 reference genome.

```bash
#!/bin/bash
# genome index with snps
wget https://cloud.biohpc.swmed.edu/index.php/s/grcm38_snp/download -O Hisat2_prebuilt_GRCM38_snp.tar.gz
tar -xf Hisat2_prebuilt_GRCM38_snp.tar.gz

# genome index with transcripts and SNPs
wget https://cloud.biohpc.swmed.edu/index.php/s/grcm38_snp_tran/download -O Hisat2_prebuilt_GRCM38_transcripts_snp.tar.gz
tar -xf Hisat2_prebuilt_GRCM38_transcripts_snp.tar.gz

# delete the .tar.gz only keeping the extracted folder
rm *.tar.gz # make sure to run where only the download .tar.gz are present
```

The above commands can be used to download and decompress the taballs from the Hisat2 download page. The paths to the extarcted genome index folder should needs to be provided for the alignment.

### 2.2 Perform sequence alignment

* Perform sequence alignment in a local computing environment 

    ```bash
    #!/bin/bash
    bash src/sh/align_reads.sh --help
    ```
    ```text
    Usage: 
    src/sh/align_reads.sh -i target_dir -x genome_index_path -n genome_index_name  -o out_dir
        -i Path to the target directory where trimmed fastq files are stored
        -x Path to the Hisat2 genome index
        -n Name of the Hisat2 genome index
        -o Path to the directory where the outputs will be written
    ```
    Note: 
    `-x genome_index_path` is equivalent to setting the `HISAT2_INDEXES` environment variable; where as `-n genome_index_name` should specify the base name of the index files.  The basename is the name of any of the index files up to but not including the final .1.ht2 / etc. `-i target_dir` should be set on the output directory  generated through the `src/sh/trim_fastq.sh` script.

* Perform sequence alignment through a slurm job (UVA internal on Rivanna)

    ```bash
    #!/bin/bash
    sbatch src/slurm/align_reads.slurm 
    ```
    The user may modify the `target_dir`, `genome_index_path`, `genome_index_name`, and `out_dir` in the slurm script as needed.

### 2.3 Generate sorted and indexed BAM files

* Generate BAM files in a local environment

    ```bash
    #!/bin/bash
    bash src/sh/unsorted_sam_to_sorted_bam.sh --help
    ```
    ```text
    Usage: 
    src/sh/unsorted_sam_to_sorted_bam.sh -i target_dir -o out_dir
        -i Path to the target directory where unsorted sam files are present
        -o Path to the directory where the outputs will be written
    ```

* Generate BAM files through a slurm job (UVA internal on Rivanna)

    ```bash
    #!/bin/bash
    sbatch src/slurm/unsoerted_sam_to_sorted_bam.slurm 
    ```
    The user may modify the `target_dir`, and `out_dir` in the slurm script as needed.

### 2.4 Get alignment statistics from the sorted BAM files

* Get alignment statistics in a local environment

    ```bash
    #!/bin/bash
    bash src/sh/get_alignment_stat.sh --help
    ```
    ```text
    Usage: 
    src/sh/get_alignment_stat.sh -i target_dir -o out_dir
        -i Path to the target directory where unsorted sam files are present
        -o Path to the directory where the outputs will be written
    ```

* Get alignment statistics through a slurm job (UVA internal on Rivanna)

    ```bash
    #!/bin/bash
    sbatch src/slurm/get_alignment_stat.slurm
    ```
    The user may modify the `input_dir`, and `output_dir` in the slurm script as needed.

### 2.5 Summarize alignment statistics

* Summarize alignment statistics with a R script
    ```bash
    #!/bin/bash
    Rscript src/R/summarize_alignment_stats.R --help
    ```
    ```text
    Options:
    -i INPUT, --input=INPUT
            Path to the folder where the outputs from 'get_alignment_stat.sh' are stored

    -o OUT_DIR, --out_dir=OUT_DIR
            A folder where the output will be written

    -h, --help
            Show this help message and exit
    ```
* Summarize alignment statistics with a slurm job (UVA internal on Rivanna)
    ```bash
    #!/bin/bash
    sbatch src/slurm/summarize_alignment_stats.slurm
    ```
    The user may modify the `target_dir`, and `out_dir` in the slurm script as needed.


## 3. Assemble RNA-Seq alignments into transcripts

### 3.1 Create sample-level transcript assemby
    
* Create sample-level transcript assemby in a local environment

    ```bash
    #!/bin/bash
    bash src/sh/compute_transcript_assembly.sh --help
    ```
    ```text
    Usage: 
    src/sh/compute_transcript_assembly.sh -i target_dir -r ref_annotation -o out_dir
        -i Path to the target directory where the sorted BAM files are present
        -r Path to the reference genome annotation (GTF)
        -o Path to the directory where the outputs will be written
    ```
* Create sample-level transcript assemby with a slurm job (UVA internal on Rivanna)
    
    ```bash
    #!/bin/bash
    sbatch src/slurm/compute_transcript_assembly.slurm
    ```
    The user may modify the `target_dir`, `annotation`, and `out_dir` in the slurm script as needed.

---
Note: 
* This step needs a reference annotation file that can be downloaded from the UCSC [goldenpath/mm10](https://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/genes/) and other online sources.

* The user must make sure that the chromosome names in the BAM and the supplied GTF are consistent (i.e. either `chr1`..`chrM` or `1`..`M`).

* When using the prebuilt GRCm38 genome index provided by Hisat2 (for alignment), the user must update the GTF file to get consistent chromosome names (i.e `chr1` --> `1`).
    ```bash
    #!/bin/bash
    sed 's/\bchr\([0-9XYM]*\)/\1/' mm10.ncbiRefSeq.gtf > mm10.ncbi_RefSeq_clean.gtf
    ```

### 3.2 Merge sample-level assemblies into a concensus assembly of non redundant transcripts

* Merge sample assemblies in a local environment

    ```bash
    #!/bin/bash
    bash src/sh/merge_transcript_assemblies.sh --help
    ```

    ```text
    Usage: 
    src/sh/merge_transcript_assemblies.sh -i target_dir -r ref_annotation -o out_dir
        -i Path to the target directory sample-level gtf files are present
        -r Path to the reference genome annotation (GTF)
        -o Path to the directory where the outputs will be written
    ```
* Merge sample assemblies with a slurm job (UVA internal on Rivanna)
    ```bash
    #!/bin/bash
    sbatch src/slurm/merge_transcript_assemblies.slurm
    ```
    The user may modify the `target_dir`, `annotation`, and `out_dir` in the slurm script as needed.

### 3.3 Create sample-level transcript assemby using the concensus assembly

Generate individual sample-level assembly using the script from the section 3.1; the `ref_annotation` in this case is the merged gtf generated from the section 3.2. An additional slurm script  `compute_transcript_assembly_consensus.slurm` has been provided for this purpose. As in the section 3.1, this script uses the `src/sh/compute_transcript_assembly.sh`.

## 4. Get abundances

### 4.1 Merge and filter gene level abundances

* Merge and filter gene level abundances in a local environment

    ```bash
    #!/bin/bash
    bash src/sh/merge_and_filter_gene_abundances.sh --help
    ```
    ```text
    Usage: 
    src/sh/merge_and_filter_gene_abundances.sh -i target_dir -o out_dir
        -i Path to the target directory where the *gene_abundance.tab files are present (results from the previous step)
        -o Path to the directory where the outputs will be written
    ```
* Merge and filter gene level abundances with a slurm job (UVA internal on Rivanna)

    Due to the non-resource intensive nature of the above script, adedicated slurm script is not provided. Users are encouraged to run this script in the interactive mode (with `ijob` command). For more details, see [notes for rivanna Users](Rivanna_UVA_internal.md).

    ```bash
    #!/bin/bash
    # example
    ijob -A <account> -p <partition> -N 1 bash bash src/sh/merge_and_filter_gene_abundances.sh -i <target_dir> -o <out_dir>
    ```

### 4.2 Prepare gene and transcript level count matrix

* Prepare count matrices in a local environment
    [stringtie](https://github.com/gpertea/stringtie/tree/master) provides a python script ([prepDE.py](../src/Py/prepDE.py)) that can easily convert the GTF files into count matrices. Using a custom script a list of the GTF files are prepared and then fed into this script.

    ```bash
    #!/bin/bash
    bash src/sh/generate_count_matrices.sh --help
    ```
    ```text
    Usage: 
    src/sh/generate_count_matrices.sh -i target_dir -o out_dir
        -i Path to the target directory where the *_assembly.gtf files are present (results from the section 3.3)
        -o Path to the directory where the outputs will be written
    ```
* Prepare count matrices with a slurm job (UVA internal on Rivanna)

    ```bash
    #!/bin/bash
    sbatch src/slurm/generate_count_matrices.slurm
    ```
    The user may modify the `target_dir` and `out_dir` in the slurm script as needed.

### 4.3 Filter gene  level count matrix

* Filter gene  level count matrix with a R script

    ```bash
    Rscript src/R/filter_gene_count_matrix.R --help
    ```
    
    ```text
    Options:
        -i INPUT, --input=INPUT
                Path to the gene_count_matrix.csv file is present

        -g GENE_LIST, --gene_list=GENE_LIST
                Path to the gene_count_filt_0.1TPM_twenty_percent file

        -o OUT_DIR, --out_dir=OUT_DIR
                A folder where the output will be written

        -h, --help
                Show this help message and exit
    ```
* Filter gene  level count matrix with a a slurm job (UVA internal on Rivanna):

    Due to the non-resource intensive nature of the above script, adedicated slurm script is not provided. Users are encouraged to run this script in the interactive mode (with `ijob` command)