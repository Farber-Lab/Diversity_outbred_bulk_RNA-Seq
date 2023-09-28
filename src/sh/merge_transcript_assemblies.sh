#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -r ref_annotation -o out_dir"
   echo -e "\t-i Path to the target directory sample-level gtf files are present"
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


echo "Scanning target directory for sample files"
files=$(find ${target_dir} | grep -i "_assembly\.gtf$")

echo "Creating a sample list"
touch "${out_dir}/sample_list.txt"

for file in "${files[@]}"; do
    echo "$file" >> "${out_dir}/sample_list.txt"
done

echo "Merging GTF files into a non-redundent set of transcripts"
cmd="stringtie --merge -G ${ref_annotation} -o ${out_dir}/merged_assembly.gtf ${out_dir}/sample_list.txt"
echo "Running ${cmd}"
eval "${cmd}"