#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -t 48:00:00
#SBATCH -p largemem
#SBATCH -A cphg-farber
#SBATCH -o job_logs/trim_fastq2.output
#SBATCH -e job_logs/trim_fastq2.error


#--------
# load trimmomatic
module load trimmomatic/0.39

#------------
# Setup
target_dir="/project/farber_lab/Users/Current_users/Saikat_B/AN00004532/"
out_dir="Results/"
adapter_file="Illumina_TruSeq_adapters.fasta"
window="4:25"
min_len="50"
trimmomatic="$EBROOTTRIMMOMATIC/trimmomatic-0.39.jar"


#--------------
# run trimmomatic
bash src/sh/trim_fastq.sh -i ${target_dir} -o ${out_dir} -a ${adapter_file} -w ${window} -m ${min_len} -t ${trimmomatic}