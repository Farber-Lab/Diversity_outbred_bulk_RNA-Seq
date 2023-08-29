#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH -t 48:00:00
#SBATCH -p largemem
#SBATCH -A cphg-farber
#SBATCH -o job_logs/prepare_genome_build.output
#SBATCH -e job_logs/prepare_genome_build.error


#--------
# load python3 and hisat2
module load gcc/9.2.0
module load openmpi/3.1.6
module load python/3.8.8
module load hisat2/2.1.0

#------------
# Setup
genome_fasta="/project/farber_lab/Dataset/Public_data/Mouse/Ref_genome_GRCm38/Mus_musculus.GRCm38.dna_sm.toplevel.fa"
snp_file="/project/farber_lab/Dataset/Public_data/Mouse/Ref_genome_GRCm38/Annotation/snp142.txt"
python_script="src/Py/hisat2_extract_snps_haplotypes_UCSC.py"
out_dir="/project/farber_lab/Users/Current_users/Saikat_B/Diversity_outbred_bulk_RNA-Seq/Results/Genome_build/"

#--------------
# prepare genome build
bash src/sh/prepare_genome_build.sh -i ${genome_fasta} -s ${snp_file} -p ${python_script} -o ${out_dir}
