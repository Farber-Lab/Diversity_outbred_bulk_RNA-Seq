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

# Begin script in case all parameters are correct
now=$(date)
echo "_________________________"
echo "${now}"
echo "Processing SAM files"
target_dir=$(realpath ${target_dir})
echo "Target: ${target_dir}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "out_dir: ${out_dir}"
cd ${out_dir}
echo "_________________________"

echo "Scanning target directory for samples"
files=$(find ${target_dir} | grep -i ".sam")

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
        sample_files=($(find ${target_dir}/${sample} | grep -i ".sam"))
        sample_sam=${sample_files[0]}
        echo "Sample_sam:${sample_sam}"
        echo "Processing SAM"
        cmd_sam2bam="samtools view ${sample_sam} -O BAM -o ${sample_out_dir}/${sample}_aligned_unsorted.bam --threads 10"
        echo "Convering SAM to BAM:${cmd_sam2bam}"
        eval "${cmd_sam2bam}"
        sample_bam=${sample_out_dir}/${sample}_aligned_unsorted.bam
        sample_bam=$(realpath ${sample_bam})
        cmd_sortbam="samtools sort ${sample_bam} -O BAM  -o ${sample_out_dir}/${sample}_aligned_sorted.bam --write-index --threads 10"
        echo "Soring BAM:${cmd_sortbam}"
        eval "${cmd_sortbam}"
    fi
    
done
