#!/bin/bash


helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -o out_dir"
   echo -e "\t-i Path to the target directory where unsorted sam files are present"
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


# Begin script in case all parameters are corrects
now=$(date)
echo "_________________________"
echo "${now}"
echo "Fetching stats from BAM files"
target_dir=$(realpath ${target_dir})
echo "Target: ${target_dir}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "out_dir: ${out_dir}"
echo "_________________________"

echo "Scanning target directory for samples"
files=$(find ${target_dir} | grep -i "_sorted.bam")

echo "Extracting sample names"
samples=($(echo "$files" | awk -F'/' '{split($NF, a, "_"); print a[1]}' | sort | uniq))
echo "found:${#samples[@]} samples"


for sample in "${samples[@]}"; do
   echo "Processing sample=${sample}"
   sample_files=($(find ${target_dir}/${sample} | grep -i "_sorted\.bam$"))
   sample_bam=${sample_files[0]}
   echo "Sample_BAM:${sample_bam}"
   echo "Fetching statistics for sample ${sample}"
   cmd_flagstat="samtools flagstat -@ 10 ${sample_bam} > ${out_dir}/${sample}_stat.txt"
   echo "Running:${cmd_flagstat}"
   eval "${cmd_flagstat}"
    
    
done


echo "Done!"