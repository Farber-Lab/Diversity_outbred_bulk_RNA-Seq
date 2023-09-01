#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i genome_fasta -s SNP_file -o out_dir -p hisat2_extract_snps_haplotypes_UCSC.py"
   echo -e "\t-i Path to the reference genome (to be used for the alignment)"
   echo -e "\t-s Path to the SNP file (to be used for the alignment)"
   echo -e "\t-p Path to the hisat2_extract_snps_haplotypes_UCSC.py script"
   echo -e "\t-o Path to the directory where the outputs will be written"
   exit 1 # Exit script after printing help
}

while getopts ":i:s:p:o:" opt
do
   case "$opt" in
      i ) genome_fasta="$OPTARG" ;;
      s ) snp_file="$OPTARG" ;;
      p ) python_script="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


# Print helpFunction in case parameters are empty
if [ -z "$out_dir" ] || [ -z "$genome_fasta" ] || [ -z "$snp_file" ] || [ -z "$python_script" ]
then
   echo "All the parameters are required!";
   helpFunction
fi


# Begin script in case all parameters are correct
now=$(date)
echo "_________________________"
echo "${now}"
echo "Preparing genome build..."
genome_fasta=$(realpath ${genome_fasta})
echo "Using ${genome_fasta}"
snp_file=$(realpath ${snp_file})
echo "Using ${snp_file}"
hisat_snps_py=${python_script}
hisat_snps_py=$(realpath ${python_script})
echo "Python script: ${hisat_snps_py}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "out_dir: ${out_dir}"
cd ${out_dir}
echo "_________________________"

echo "Extracting SNPs Haplotypes"
python3 ${hisat_snps_py} ${genome_fasta} ${snp_file} genome

echo "Building genome index"
hisat2-build --noauto --bmaxdivn 2 --dcv 2048 -p 16 --large-index ${genome_fasta} --snp genome.snp --haplotype genome.haplotype genome_snp

echo "Done!"