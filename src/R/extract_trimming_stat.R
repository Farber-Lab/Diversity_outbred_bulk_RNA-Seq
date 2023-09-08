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
    c("-e", "--error_log"),
    default = "job_logs/trim_fastq2.error",
    help = "Path to the Trimmomatic error log file"
  ),
  optparse::make_option(
    c("-c", "--console_log"),
    default = "job_logs/trim_fastq2.output",
    help = "Path to the Trimmomatic console log file"
  ),
  optparse::make_option(
    c("-o","--out_dir"),
    default = "Results/Trim_stat/",
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
if (is.null(args$error_log)) {
  optparse::print_help(arg_parser)
  stop("--error_log not supplied!")
}
if (is.null(args$console_log)) {
  optparse::print_help(arg_parser)
  stop("--console_log not supplied!")
}

# -------
# check output directory
out_dir <- paste0(getwd(),"/",args$out_dir)

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
# check output directory end

# read input files
Trimmomatic_error_log <- readLines(args$error_log,skipNul = TRUE)
Trimmomatic_console_log <- readLines(args$console_log,skipNul = TRUE)


# Filter lines that contain the statistics
console_log_lines_index <- grep("Processing sample=", Trimmomatic_console_log)

console_log_lines <- as.character(na.omit(sapply(console_log_lines_index, function(x){
  line <- x+1
  next_line <-Trimmomatic_console_log[line]
  if(next_line != "Folder exists in the destination skipping sample"){
    return(Trimmomatic_console_log[x])
  } else{
    return(NA)
  }
})))

error_log_lines <- grep("Input Read Pairs:", Trimmomatic_error_log, value = TRUE)

sample_process <- length(console_log_lines)
sample_process_complete <- length(error_log_lines)


if(sample_process != sample_process_complete){
  diff <- (sample_process - sample_process_complete)
  console_log_lines <- console_log_lines[1:(sample_process - diff)]
} else{
  console_log_lines <- console_log_lines
}


logger::log_info("Exatcting trimming statistics")

# Extract data from the relevant lines
samples <- sapply(console_log_lines, function(x){sub("Processing sample=","",x)})
input_reads <- sapply(error_log_lines, function(x) sub("Input Read Pairs: ([0-9]+).*", "\\1", x))
both_surviving <- sapply(error_log_lines, function(x) sub(".*Both Surviving: ([0-9]+).*", "\\1", x))
forward_only <- sapply(error_log_lines, function(x) sub(".*Forward Only Surviving: ([0-9]+).*", "\\1", x))
reverse_only <- sapply(error_log_lines, function(x) sub(".*Reverse Only Surviving: ([0-9]+).*", "\\1", x))
dropped <- sapply(error_log_lines, function(x) sub(".*Dropped: ([0-9]+).*", "\\1", x))

# Create a data frame
df <- data.frame(
  Sample = samples,
  Input_reads = as.numeric(input_reads),
  Reads_after_trimming = as.numeric(both_surviving),
  Forward_only = as.numeric(forward_only),
  Reverse_only = as.numeric(reverse_only),
  Dropped = as.numeric(dropped)
)

df$remaining_reads_pct <- round((df$Reads_after_trimming/df$Input_reads)*100,2)
df$dropped_pct <- round((100 - df$remaining_reads_pct), 2)

rownames(df) <- NULL

trim_stat_out <- paste0(args$out_dir, "trimming_statistics.tsv")

if(file.exists(trim_stat_out)){
  logger::log_info(
    paste("Writing\n", "Found existing file, appending values!")
  )
  df_ <- data.table::fread(trim_stat_out)
  df_new <- as.data.frame(rbind(df_, df))
  df_final <- df_new
} else{
  logger::log_info(
    paste("Writing to\n", trim_stat_out)
  )
  df_final <- df
}

df_final <- df_final %>% dplyr::distinct(.keep_all = TRUE)

write.table(
  df_final,
  trim_stat_out,
  quote = FALSE,
  row.names = FALSE,
  sep = "\t"
)
