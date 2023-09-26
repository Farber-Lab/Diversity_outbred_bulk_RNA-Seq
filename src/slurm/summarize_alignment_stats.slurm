#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -p standard
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/summarize_alignment_stat.output
#SBATCH -e job_logs/summarize_alignment_stat.error


# Load modules
module load gcc/9.2.0
module load openmpi/3.1.6
module load R/4.2.1

# Setup
input_dir="Results/Alignment_GRCm38_snp_BAM_statistics"
output_dir="Results/Alignment_GRCm38_snp_BAM_statistics_summary"

# Run R script
Rscript src/R/summarize_alignment_stats.R -i ${input_dir} -o ${output_dir}