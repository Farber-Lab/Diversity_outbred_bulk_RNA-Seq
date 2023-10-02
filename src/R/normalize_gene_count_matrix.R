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
  "logger",
  "DESeq2"
)

dependency_manager(deps)

# argument parser for the script
args_list <- list(
  optparse::make_option(
    c("-i", "--input"),
    default = "Results/Count_matrices/gene_abundance_matrix_filter.csv",
    help = "Path to the gene_count_matrix.csv file is present",
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

logger::log_info("Reading count matrix")

#read in the RNA-seq counts
counts = read.csv(
    args$input, 
    stringsAsFactors = FALSE,
    row.names = 1,
    check.names = FALSE
)

logger::log_info("Running DESeq2::vst")

# normalize by stabilizing variants
dds.vst = DESeq2::varianceStabilizingTransformation(as.matrix(counts))

#transpose
dds.vst_transpose = t(dds.vst)
dds.vst_n = as.data.frame(dds.vst_transpose)


logger::log_info("Performing quantile nomalization")
#perform quantile-based inverse normal transform. aka match each gene datapoint to a quantile, then match to quantile in normal distribution
#from https://www.nature.com/articles/nature11401#s1 (FTO genotype BMI Visscher et al)

for(col in 1:ncol(dds.vst_transpose)){
  dds.vst_transpose[,col] = qnorm((rank(dds.vst_transpose[,col],na.last="keep")-0.5)/sum(!is.na(dds.vst_transpose[,col])))
}


# create a dataframe
dds.vst_df <- as.data.frame(dds.vst_transpose)

# create a column with mouse ids
dds.vst_df$Mouse.ID = rownames(dds.vst_df)

# make the Mouse.ID the first column
dds.vst_df = dds.vst_df[,c(ncol(dds.vst_df), 1:(ncol(dds.vst_df)-1))]

out_file_vst_qnorm <- paste0(out_dir,"/", 'gene_abundance_vst_qnorm.csv')

logger::log_info(
    paste("Writing out_file_vst_qnorm")
)

#write
write.table(
    dds.vst_df, 
    out_file_vst_qnorm, 
    row.names = FALSE, 
    col.names = TRUE, 
    quote = FALSE, 
    sep = ","
)

# create nohead
dds.vst_df_nohead = dds.vst_df[,-1]

out_file_vst_qnorm_nohead <- paste0(out_dir,"/", 'gene_abundance_vst_qnorm_nohead.csv')

# write nohead
write.table(
    dds.vst_df_nohead, 
    out_file_vst_qnorm_nohead, 
    row.names = FALSE, 
    col.names = FALSE, 
    quote = FALSE, 
    sep = ","
)

logger::log_info(
    paste("Done!")
)
