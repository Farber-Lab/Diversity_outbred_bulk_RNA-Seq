#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -p largemem
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/align_reads.output
#SBATCH -e job_logs/align_reads.error


#--------
# load hisat2
module load gcc/9.2.0
module load hisat2/2.1.0

#------------
# Setup
target_dir="Results/Fastq_trimmed/"
genome_index_path="Results/Genome_build_snp/grcm38_snp"
genome_index_name="genome_snp"
out_dir="Results/Alignment_GRCm38_snp"

#--------------
# align reads
bash src/sh/align_reads.sh -i ${target_dir} -x ${genome_index_path} -n ${genome_index_name} -o ${out_dir}