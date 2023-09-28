#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -p standard
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/merge_transcript_assemblies.output
#SBATCH -e job_logs/merge_transcript_assemblies.error

#--------
# load stringtie
module load gcc/9.2.0
module load stringtie/2.1.0

#------------
# Setup
target_dir="Results/transcript_assembly/"
annotation="Results/Ref_annotations/mm10.ncbi_RefSeq_clean.gtf"
out_dir="Results/Transcript_assembly_merged"

#---------
#--------
# run stringtie
bash src/sh/merge_transcript_assemblies.sh -i ${target_dir} -r ${annotation} -o ${out_dir}
