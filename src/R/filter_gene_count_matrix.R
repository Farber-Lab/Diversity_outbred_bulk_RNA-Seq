# clear globalenv
rm(list=ls())

# load dependency manager function
source("src/R/R_dependency_manager.R")

#--------
deps <- c(
  "plyr",
  "dplyr",
  "logger",
  "optparse",
  "logger"
)

dependency_manager(deps)

# argument parser for the script
args_list <- list(
  optparse::make_option(
    c("-i", "--input"),
    default = "Results/Count_matrices/gene_count_matrix.csv",
    help = "Path to the gene_count_matrix.csv file is present",
  ),
  optparse::make_option(
    c("-g", "--gene_list"),
    default = "Results/Gene_abundance_merged/gene_count_filt_0.1TPM_twenty_percent",
    help = "Path to the gene_count_filt_0.1TPM_twenty_percent file"
  ),
  optparse::make_option(
    c("-o","--out_dir"),
    default = "Results/Count_matrices",
    help = "A folder where the output will be written"
  )
)

arg_parser <- optparse::OptionParser(
  option_list = args_list
)
args <- optparse::parse_args(
  arg_parser
)

# check if the input has been provided
if (is.null(args$input)) {
  optparse::print_help(arg_parser)
  stop("--input not supplied!")
}

if (is.null(args$gene_list)) {
  optparse::print_help(arg_parser)
  stop("--gene_list not supplied!")
}


# check for output directory
out_dir <- args$out_dir

logger::log_info(
  "searching out_dir:\n",
  out_dir
)
if(!dir.exists(out_dir)){
  dir.create(
    out_dir
  )
  logger::log_warn("Not Found!\ncreated", out_dir)
} else{
  logger::log_info("Found..")
}

logger::log_info("Reading gene abundance matrix")

gene_matrix <- read.csv(
    args$input,
    stringsAsFactors=F, header=T, check.names=F
)

twenty_percent_samples <- round(ncol(gene_matrix)*(20/100))

genes_over6reads_over_twenty_percent_samps = c()

for(i in 1:nrow(gene_matrix)){
if (length(which(gene_matrix[i,2:ncol(gene_matrix)] > 6))>38){
genes_over6reads_over_twenty_percent_samps= append(genes_over6reads_over_twenty_percent_samps, gene_matrix[i,1])
}
}

genes_over6reads_over_twenty_percent_samps_df <- plyr::ldply(
    genes_over6reads_over_twenty_percent_samps, function(x){
        tmp <- strsplit(x, "\\|")[[1]]
        data.frame(id=tmp[1], gene=tmp[2])
    }, .progress="text"
)

gene_list <- read.csv(args$gene_list, stringsAsFactors=F)

logger::log_info("Filtering gene abundance matrix")

idx <- which(genes_over6reads_over_twenty_percent_samps_df$id %in% gene_list[,1])

z=unlist(genes_over6reads_over_twenty_percent_samps[idx])

gene_matrix_final=gene_matrix[which(gene_matrix[,1] %in% z),]

out_file <- paste0(args$out_dir, "/gene_abundance_matrix_filter.csv")

logger::log_info(
    paste("Writing", out_file)
)

write.csv(
    gene_matrix_final, 
    out_file,
    row.names=F, 
    quote=F
)


logger::log_info("Done!")
