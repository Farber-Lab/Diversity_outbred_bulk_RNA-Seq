#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -p largemem
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/compute_transcript_abundance.output
#SBATCH -e job_logs/compute_transcript_abundance.error

#--------
# load stringtie
module load gcc/9.2.0
module load stringtie/2.1.0

#------------
# Setup
target_dir="Results/Alignment_GRCm38_snp_BAM/"
annotation="Results/Ref_annotations/mm10.ncbi_RefSeq_clean.gtf"
out_dir="Results/Abudances"

#--------
# run stringtie
bash src/sh/compute_transcript_abundance.sh -i ${target_dir} -r ${annotation} -o ${out_dir}