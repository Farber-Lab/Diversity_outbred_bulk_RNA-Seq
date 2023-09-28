#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -p standard
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/compute_transcript_assembly_consensus.output
#SBATCH -e job_logs/compute_transcript_assembly_consensus.error

#--------
# load stringtie
module load gcc/9.2.0
module load stringtie/2.1.0

#------------
# Setup
target_dir="Results/Alignment_GRCm38_snp_BAM/"
annotation="Results/Transcript_assembly_merged/merged_assembly.gtf"
out_dir="Results/Transcript_assembly_consensus"

#--------
# run stringtie
bash src/sh/compute_transcript_assembly.sh -i ${target_dir} -r ${annotation} -o ${out_dir}