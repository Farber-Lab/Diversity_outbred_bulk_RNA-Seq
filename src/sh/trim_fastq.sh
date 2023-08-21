#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -o out_dir -a adapter_file -w window -m min_len -t trimmomatic alias"
   echo -e "\t-i path to directory with fastq files"
   echo -e "\t-o Path to the directory where the outputs will be written"
   echo -e "\t-a Path to the adapter fasta file"
   echo -e "\t-w Sliding Window"
   echo -e "\t-m Minimum read length"
   echo -e "\t-t Trimmomatic alias"
   exit 1 # Exit script after printing help
}

while getopts "i:o:a:w:m:t:" opt
do
   case "$opt" in
      i ) target_dir="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      a ) adapter_file="$OPTARG" ;;
      w ) window="$OPTARG" ;;
      m ) min_len="$OPTARG" ;;
      t ) trimmomatic="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$target_dir" ] || [ -z "$out_dir" ] || [ -z "$adapter_file" ] || [ -z "$window" ] || [ -z "$min_len" ] || [ -z "$trimmomatic" ]
then
   echo "All the parameters are required!";
   helpFunction
fi


now=$(date)
dt=$(date +"%d%m%y")
echo "_________________________"
echo "Trim Illumina reads with trimmomatic..."
echo "${now}"
target_dir=$(realpath ${target_dir})
echo "target: ${target_dir}"
out_dir=${out_dir}Fastq_trimmed_${dt}
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
adapter_file=$(realpath ${adapter_file})
echo "adapter_file: ${adpter_file}"
echo "sliding_window: ${window}"
echo "min_length: ${min_len}"
echo "out_dir: ${out_dir}"
echo "_________________________"

echo "Scanning for all .fastq files"
files=$(ls ${target_dir}/*.fastq.gz)

echo "Extracting sample names"
samples=($(echo "$files" | awk -F'/' '{split($NF, a, "_"); print a[1]}' | sort | uniq))
echo "found:${#samples[@]} samples"

for sample in "${samples[@]}"; do
    echo "Processing sample=${sample}"
    sample_out_dir=${out_dir}/${sample}/
    echo "Creating ${sample_out_dir}"
    mkdir -p ${sample_out_dir}
    sample_files=($(echo "${files}" | grep "/${sample}_"))
    len_files=${#sample_files[@]}
    if [[ $len_files -eq 2 ]]; then
        echo "Running paired End"
        java -jar ${trimmomatic} PE -threads 10 -phred33 \
        -trimlog ${sample_out_dir}/log.txt \
        ${sample_files[0]} ${sample_files[1]} \
        ${sample_out_dir}/${sample}_R1_paired.fastq.gz ${sample_out_dir}/${sample}_R1_unpaired.fastq.gz \
        ${sample_out_dir}/${sample}_R2_paired.fastq.gz ${sample_out_dir}/${sample}_R2_unpaired.fastq.gz \
        ILLUMINACLIP:${adapter_file}:2:30:10 SLIDINGWINDOW:${window} MINLEN:${min_len} \
        > ${sample_out_dir}/${sample}_trimstat.txt
    else
        echo "Expected paired-end sequences; Provided sequences are likely single-end"
        exit 1;
    fi
done

echo "Trimming complete!"