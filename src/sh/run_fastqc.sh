#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -o out_dir -m run_mode"
   echo -e "\t-i path to directory with fastq files"
   echo -e "\t-o Path to the directory where the outputs will be written"
   echo -e "\t-m value should be one of Trimmed/Untrimmed "
   exit 1 # Exit script after printing help
}

while getopts "i:o:m:" opt
do
   case "$opt" in
      i ) target_dir="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      m ) run_mode="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$target_dir" ] || [ -z "$out_dir" ] || [ -z "$run_mode" ]
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
echo "_________________________"

# move to out directory
echo "out_dir: ${out_dir}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
cd ${out_dir}

# find fastq files
if [[ $run_mode == "Trimmed" ]]; then
  # Trimmed mode
  echo "QC statered in Trimmed Mode"
  # iterate over each dir
  files=$(find ${target_dir} | grep -i "_paired.fastq.gz")
  # end Trimmed mode
elif [[ $run_mode == "Untrimmed" ]]; then
  # Untrimmed mode
  echo "QC statered in Untrimmed Mode"
  echo "Scanning for all .fastq files"
  files=$(ls ${target_dir}/*.fastq.gz)
  # end Untrimmed mode
else
  echo "Invalid Run Mode Specified"
fi

# get files
files=( ${files} )
echo "found:${#files[@]} files"

# process files
for f in ${files[@]}
do
echo "Processing: ${f}"
file_name=$(basename ${f})
sample="${file_name%.fastq.gz}"
sample_fqc_zip="${out_dir}/${sample}_fastqc.zip"
sample_fqc_html="${out_dir}/${sample}_fastqc.html"
if [ -f "${sample_fqc_zip}" ] || [ -f "${sample_fqc_html}" ]
then
echo "output exists in the destination skipping sample"
else
echo "output does't exists in the destination, processing"
fastqc -t 10 $(realpath ${f}) -o .
fi
done

echo "Done!"