#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH -p standard
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/unsorted_sam_to_sorted_bam.output
#SBATCH -e job_logs/unsorted_sam_to_sorted_bam.error


#-------
# load samtools
module load samtools/1.12

#------------
# Setup
target_dir="Results/Alignment_GRCm38_snp/"
out_dir="Results/Alignment_GRCm38_snp_BAM/"

#--------------
# convert sam to BAM
bash src/sh/unsorted_sam_to_sorted_bam.sh -i ${target_dir} -o ${out_dir}