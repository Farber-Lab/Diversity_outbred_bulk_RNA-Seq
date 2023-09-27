#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -r ref_annotation -o out_dir"
   echo -e "\t-i Path to the target directory where the sorted BAM files are present"
   echo -e "\t-r Path to the reference genome annotation (GTF)"
   echo -e "\t-o Path to the directory where the outputs will be written"
   exit 1 # Exit script after printing help
}

while getopts ":i:r:o:" opt
do
   case "$opt" in
      i ) target_dir="$OPTARG" ;;
      r ) ref_annotation="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$out_dir" ] || [ -z "$target_dir" ] || [ -z "$ref_annotation" ]
then
   echo "All the parameters are required!";
   helpFunction
fi

now=$(date)
echo "_________________________"
echo "${now}"
echo "Computation of transcript abundance...."
target_dir=$(realpath ${target_dir})
echo "Target: ${target_dir}"
ref_annotation_path=$(realpath ${ref_annotation})
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "out_dir: ${out_dir}"
echo "_________________________"

echo "Scanning target directory for samples"
files=$(find ${target_dir} | grep -i "_aligned_sorted\.bam$")

echo "Extracting sample names"
samples=($(echo "$files" | awk -F'/' '{split($NF, a, "_"); print a[1]}' | sort | uniq))
echo "found:${#samples[@]} samples"

for sample in "${samples[@]}"; do
    echo "Processing sample=${sample}"
    sample_out_dir=${out_dir}/${sample}/
    if [ -d "$sample_out_dir" ]; then
        echo "Folder exists in the destination skipping sample"
    else
        echo "Creating ${sample_out_dir}"
        mkdir -p ${sample_out_dir}
        sample_file=($(find ${target_dir}/${sample} -type f | grep -i "_aligned_sorted\.bam$" ))
        bam_file=${sample_file[0]}
        echo "BAM:${bam_file}"
        echo "Starting assembly"
        cmd="stringtie -e -p 10 -v -G ${ref_annotation_path} -o ${sample_out_dir}${sample}_assembly.gtf -A ${sample_out_dir}${sample}_gene_abundance.tab ${bam_file}"
        echo "Running:${cmd}"
        eval "${cmd}"
    fi
    
done