#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i target_dir -o out_dir"
   echo -e "\t-i Path to the target directory where the *gene_abundance.tab files are present (results from the previous step)"
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
echo "Computation of transcript abundance...."
target_dir=$(realpath ${target_dir})
echo "Target: ${target_dir}"
mkdir -p ${out_dir}
out_dir=$(realpath ${out_dir})
echo "out_dir: ${out_dir}"
echo "_________________________"

echo "Scanning target directory for samples"
files=$(find ${target_dir} | grep -i "_gene_abundance\.tab$")

gene_abundances_merged_out_file="${out_dir}/Merged_gene_abundances.tab"
echo "Creating:${gene_abundances_merged_out_file}"
touch "${gene_abundances_merged_out_file}"

# write the contents of gene abundance files into a combined file
for file in "${files[@]}"; do
    cat $file >> "${gene_abundances_merged_out_file}"
done

gene_abundances_merged_filt_out_file="${out_dir}/Merged_gene_abundances_filt_0.1TPM.tab"

echo "Filtering genes with abundance more than 0.1 TPM"
echo "Creating ${gene_abundances_merged_filt_out_file}"

# filter according to the TPM
awk -v outFile="$gene_abundances_merged_filt_out_file" '($9 > 0.1) {print $0 >> outFile}' "$gene_abundances_merged_out_file"

echo "Counting genes with abundance more than 0.1 TPM"
gene_pass_count_file="${out_dir}/gene_count_filt_0.1TPM"
# count  the number of genes passing the filter
awk -v outFile="$gene_pass_count_file"  '{a[$1]++;} END{for(i in a) print a[i]"  "i >> outFile}' "$gene_abundances_merged_filt_out_file"


samples=($(echo "$files" | awk -F'/' '{split($NF, a, "_"); print a[1]}' | sort | uniq))
# Calculate 20% of the length of the samples array
twenty_percent=$(( (${#samples[@]} * 20) / 100 ))

echo "Filtering genes that pass ~20% samples (i.e. ${twenty_percent})"
gene_pass_count_file_2="${out_dir}/gene_count_filt_0.1TPM_twenty_percent"
awk -v outFile="$gene_pass_count_file_2" '($1 > "${twenty_percent}") {print $2 >> outFile}' "$gene_pass_count_file"

echo "Done!"