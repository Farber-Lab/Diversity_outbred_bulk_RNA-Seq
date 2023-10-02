#!/bin/bash
#SBATCH --nodes=1
#SBATCH -p standard
#SBATCH -t 48:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/generate_count_matrices.output
#SBATCH -e job_logs/generate_count_matrices.error

#--------
# load python2.7
module load gcc/7.1.0
module load openmpi/3.1.4
module load python/2.7.16

#------------
# Setup
target_dir="Results/Transcript_assembly_consensus"
out_dir="Results/Count_matrices"

#-------------
# Run script
bash src/sh/generate_count_matrices.sh -i ${target_dir} -o ${out_dir}