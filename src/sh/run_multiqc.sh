#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -o out_dir -m run_mode"
   echo -e "\t-i path to directory with FASTQC outputs"
   echo -e "\t-o Path to the directory where the multiQC report will be written"
   exit 1 # Exit script after printing help
}

while getopts "i:o:" opt
do
   case "$opt" in
      i ) target_dir="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$target_dir" ] || [ -z "$out_dir" ]
then
   echo "All the parameters are required!";
   helpFunction
fi


# Begin script in case all parameters are correct
now=$(date)
echo "_________________________"
echo "${now}"
target_dir=$(realpath ${target_dir})
echo "target: ${target_dir}"
echo "out_dir: ${out_dir}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "_________________________"

# move to target directory
cd ${target_dir}

# run multiqc
multiqc --outdir ${out_dir} .


echo "Done!"


