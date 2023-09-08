#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH -p largemem
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/unsorted_sam_to_sorted_bam_transcript_snp.output
#SBATCH -e job_logs/unsorted_sam_to_sorted_bam_transcript_snp.error


#-------
# load samtools
module load samtools/1.12

#------------
# Setup
target_dir="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/alignment_transcript_snp"
out_dir="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/alignment_transcript_snp_BAM"

#--------------
# convert sam to BAM
bash src/sh/unsorted_sam_to_sorted_bam.sh -i ${target_dir} -o ${out_dir}