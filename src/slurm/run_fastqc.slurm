#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH -t 48:00:00
#SBATCH -p largemem
#SBATCH -A cphg-farber
#SBATCH -o job_logs/run_fastqc.output
#SBATCH -e job_logs/run_fastqc.error


#--------
# load fastqc
module load fastqc/0.11.5

#------------
# Setup
target_dir="/project/farber_lab/Users/Current_users/Saikat_B/AN00004532/"
out_dir="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/FASTQC_Untrimmed"
run_mode="Untrimmed"


#--------------
# run fastqc



