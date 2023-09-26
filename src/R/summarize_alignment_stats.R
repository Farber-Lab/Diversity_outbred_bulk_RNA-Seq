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
  "ggplot2"
)

dependency_manager(deps)


# argument parser for the script
args_list <- list(
  optparse::make_option(
    c("-i", "--input"),
    default = NULL,
    help = "Path to the folder where the outputs from 'get_alignment_stat.sh' are stored"
  ),
  optparse::make_option(
    c("-o","--out_dir"),
    default = NULL,
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

logger::log_info("Summarizing alignment statistics")

# list files in the target directory
all_files_in_target <- sapply(list.files(args$input, recursive=TRUE),
  function(x){
    tmp <- paste0(args$input,"/",x)
    normalizePath(tmp)
  }
)

logger::log_info("Locating files with pattern '_stat.txt'")

# only get the files with pattern "_bamstat.txt" 
## according to 'get_alignment_stat.sh' output format
bamstat_files <- grep(
  pattern="_stat.txt", 
  x=all_files_in_target, 
  value=TRUE
)

logger::log_info(
  paste("Found", length(bamstat_files), "files!")
)

# create a summary dataframe from the BAM statistics
summary_df <- plyr::ldply(bamstat_files, function(x){
  file_path <- x
  file_path_split <- strsplit(file_path, split="/")[[1]]
  basename <- file_path_split[length(file_path_split)]
  sample <- strsplit(basename, split="\\_")[[1]][1]
  # read statistics file (generated with samtools flagstat)
  stat_file <- readLines(file_path)
  # extract statistics
  # total alignments
  total_alignment_line <- stat_file[1]
  total_alignment_line <- strsplit(total_alignment_line, split="\\+")[[1]]
  total_aligment_qc_passed <- as.numeric(gsub(" ", "", total_alignment_line[1]))
  # secondary alignments
  secondary_alignment_line <- stat_file[2]
  secondary_alignment_line <- strsplit(secondary_alignment_line, split="\\+")[[1]]
  secondary_alignment_qc_passed <- as.numeric(gsub(" ", "", secondary_alignment_line[1]))
  # alignment rate
  alignment_rate_line <- stat_file[5]
  alignment_rate_line <- strsplit(alignment_rate_line, split="\\+")[[1]]
  alignment_rate_qc_passed <- as.numeric(gsub(" ", "", alignment_rate_line[1]))
  alignment_rate_qc_passed <- round(100*(alignment_rate_qc_passed/total_aligment_qc_passed),2)
  # properly paired
  singleton_line <- stat_file[11]
  singleton_line <- strsplit(singleton_line, split="\\+")[[1]]
  singletons <- as.numeric(gsub(" ", "", singleton_line[1]))
  # create data frame
  df <- data.frame(
    sample = sample,
    total_alignments_qc_passed = total_aligment_qc_passed,
    secondary_alignments_qc_passed = secondary_alignment_qc_passed,
    alignment_rate_percentage = alignment_rate_qc_passed,
    singletons = singletons
  )
  return(df)
}, .id=NULL, .progress="text")

out_file <- paste0(out_dir, "/alignment_stats_summary.tsv")

logger::log_info(
  paste("Writing", out_file)
)

write.table(
  summary_df,
  out_file,
  row.names = FALSE,
  sep = "\t",
  quote = FALSE
)

logger::log_info("Done!")