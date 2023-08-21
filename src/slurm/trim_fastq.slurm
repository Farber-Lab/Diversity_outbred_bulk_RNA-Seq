#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=05
#SBATCH -t 02:00:00
#SBATCH -p largemem
#SBATCH -A cphg-farber
#SBATCH -o job_logs/trim_fastq.output
#SBATCH -e job_logs/trim_fastq.error


#--------
# load trimmomatic
module load trimmomatic/0.39

#------------
# Setup
target_dir="/project/farber_lab/Users/Current_users/Saikat_B/AN00004532/"
out_dir="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/"
adapter_file="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Illumina_TruSeq_adapters.fasta"
window="4:25"
min_len="50"


#--------------
# run trimmomatic
bash src/sh/trim_fastq -i ${target_dir} -o ${out_dir} -a ${adapter_file} -w ${window} -m ${min_len}