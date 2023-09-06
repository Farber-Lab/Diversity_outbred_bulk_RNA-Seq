#!/bin/bash
#SBATCH --nodes=1
#SBATCH -p standard
#SBATCH -A cphg-farber
#SBATCH -o job_logs/align_reads.output
#SBATCH -e job_logs/align_reads.error


#--------
# load hisat2
module load gcc/9.2.0
module load hisat2/2.1.0

#------------
# Setup
target_dir="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/Fastq_trimmed/"
genome_index_path="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/Genome_build/"
genome_index_name="genome_build"
out_dir="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/alignment"

#--------------
# align reads
bash src/sh/align_reads.sh -i ${target_dir} -x ${genome_index_path} -n ${genome_index_name} -o ${out_dir}