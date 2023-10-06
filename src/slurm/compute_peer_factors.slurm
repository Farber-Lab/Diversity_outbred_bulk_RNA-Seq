#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH -p largemem
#SBATCH -t 06:00:00
#SBATCH -A cphg-farber
#SBATCH -o job_logs/compute_peer.output
#SBATCH -e job_logs/compute_peer.error

# ------------
# load peer and python
module load gcc/9.2.0
module load openmpi/3.1.6
module load peer


#-------------------
# setup
input="Results/Count_matrices/gene_abundance_vst_qnorm_nohead.csv"
out_path="Results/Count_matrices"

#-------------------
# run script
python src/Py/compute_peer_factors.py -i "${input}" -o "${out_path}"
