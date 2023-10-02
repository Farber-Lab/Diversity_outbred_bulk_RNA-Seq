#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -o out_dir"
   echo -e "\t-i Path to the target directory where the *_assembly.gtf files are present (results from the section 3.3)"
   echo -e "\t-o Path to the directory where the outputs will be written"
   exit 1 # Exit script after printing help
}

while getopts ":i:o:" opt
do
   case "$opt" in
      i ) target_dir="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$out_dir" ] || [ -z "$target_dir" ]
then
   echo "All the parameters are required!";
   helpFunction
fi

now=$(date)
echo "_________________________"
echo "${now}"
echo "Generation of count matrices...."
target_dir=$(realpath ${target_dir})
echo "Target: ${target_dir}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "out_dir: ${out_dir}"
echo "_________________________"

echo "Creating count matrices"
cmd="python src/Py/prepDE.py -i ${target_dir} -l 75 -g ${out_dir}/gene_count_matrix.csv -t ${out_dir}/transcript_count_matrix.csv"
echo "Running: ${cmd}"
eval "${cmd}"
echo "Done!"