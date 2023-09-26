#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=05
#SBATCH -t 02:00:00
#SBATCH -p standard
#SBATCH -A cphg-farber
#SBATCH -o job_logs/run_multiqc.output
#SBATCH -e job_logs/run_multiqc.error


#--------
# load multiqc
module load multiqc/1.11

#------------
# Setup
target_dir="Results/FASTQC_Untrimmed"
out_dir="Results/MULTIQC_Untrimmed"


#--------------
# run multiqc
bash src/sh/run_multiqc.sh -i ${target_dir} -o ${out_dir}
