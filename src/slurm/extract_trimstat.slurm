#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=04
#SBATCH -t 01:00:00
#SBATCH -p largemem
#SBATCH -A cphg-farber
#SBATCH -o job_logs/extract_trimstat.output
#SBATCH -e job_logs/extract_trimstat.error



# load modules
#--------------
module load gcc/9.2.0
module load openmpi/3.1.6
module load R/4.2.1

# run script
#------------
Rscript src/R/extract_trimstat.R