#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -x genome_index_path -n genome_index_name  -o out_dir"
   echo -e "\t-i Path to the target directory where trimmed fastq files are stored"
   echo -e "\t-x Path to the Hisat2 genome index"
   echo -e "\t-n Name of the Hisat2 genome index"
   echo -e "\t-o Path to the directory where the outputs will be written"
   exit 1 # Exit script after printing help
}

while getopts ":i:x:n:o:" opt
do
   case "$opt" in
      i ) target_dir="$OPTARG" ;;
      x ) genome_index_path="$OPTARG" ;;
      n ) genome_index_name="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


# Print helpFunction in case parameters are empty
if [ -z "$out_dir" ] || [ -z "$target_dir" ] || [ -z "$genome_index_path" ] || [ -z "$genome_index_name" ]
then
   echo "All the parameters are required!";
   helpFunction
fi

# Begin script in case all parameters are correct
now=$(date)
echo "_________________________"
echo "${now}"
echo "Alignment of FASTQ to reference genome....."
target_dir=$(realpath ${target_dir})
echo "Target: ${target_dir}"
genome_index_path=$(realpath ${genome_index_path})
export HISAT2_INDEXES=${genome_index_path}
genome_index="${genome_index_path}/${genome_index_name}"
echo "Genome index:${genome_index}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "out_dir: ${out_dir}"
cd ${out_dir}
echo "_________________________"

echo "Scanning target directory for samples"
files=$(find ${target_dir} | grep -i "fastq.gz")

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
        sample_files=($(find ${target_dir}/${sample} | grep -i "_paired.fastq.gz"))
        fwd_paired=${sample_files[0]}
        rev_paired=${sample_files[1]}
        echo "FWD:${fwd_paired}"
        echo "REV:${rev_paired}"
        echo "Starting alignment"
        # --dta enables downstrap triptome assembly
        cmd="hisat2 --dta --threads 10 -x ${genome_index} -1 ${fwd_paired} -2 ${rev_paired} -S ${sample_out_dir}/${sample}_aligned_unsorted.sam"
        echo "Running:${cmd}"
        eval "${cmd}"
    fi
    
done


