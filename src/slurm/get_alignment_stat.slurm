#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -p largemem
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/get_alignment_stat.output
#SBATCH -e job_logs/get_alignment_stat.error


#-------
# load samtools
module load samtools/1.12

#------------
# Setup
target_dir="Results/Alignment_GRCm38_snp_BAM"
out_dir="Results/Alignment_GRCm38_snp_BAM_statistics"

#--------------
# get samtools flagstat
bash src/sh/get_alignment_stat.sh -i ${target_dir} -o ${out_dir}
