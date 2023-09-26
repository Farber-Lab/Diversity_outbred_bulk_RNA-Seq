#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -t 48:00:00
#SBATCH -p standard
#SBATCH -A cphg-farber
#SBATCH -o job_logs/run_fastqc.output
#SBATCH -e job_logs/run_fastqc.error


#--------
# load fastqc
module load fastqc/0.11.5

#------------
# Setup
target_dir="/project/farber_lab/Users/Current_users/Saikat_B/AN00004532/"
out_dir="Results/FASTQC_Untrimmed"
run_mode="Untrimmed"


#--------------
# run fastqc
bash src/sh/run_fastqc.sh -i ${target_dir} -o ${out_dir} -m ${run_mode}



