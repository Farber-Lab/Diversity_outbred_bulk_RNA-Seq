# clear globalenv
rm(list=ls())

# ------
# dependency manager
dependency_manager <- function(package_list) {
  for (package in package_list) {
    # Check if package is installed
    if (!require(package, character.only = TRUE)) {
      print(paste("Package not found:", package, ". Installing..."))
      # Check package source and install accordingly
      if(package %in% rownames(available.packages(contriburl=contrib.url("http://cran.us.r-project.org")))) {
        # Install from CRAN
        install.packages(package)
      } else if (package %in% rownames(available.packages(contriburl=contrib.url(BiocManager::repositories())))) {
        # Install from Bioconductor
        BiocManager::install(package)
      } else {
        print(paste("Package not available:", package))
      }

      # Check if the package has been installed
      if (require(package, character.only = TRUE)) {
        print(paste("Package installed and loaded:", package))
      } else {
        print(paste("Failed to install:", package))
      }
    } else {
      print(paste("Package already installed:", package))
    }
  }
}

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
    default = "job_logs/trim_fastq.error",
    help = "Path to the Trimmomatic error log file"
  ),
  optparse::make_option(
    c("-c", "--console_log"),
    default = "job_logs/trim_fastq.output",
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
console_log_lines <- grep("Processing sample=", Trimmomatic_console_log, value = TRUE)
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

logger::log_info(
  paste("Writing to\n", trim_stat_out)
)

write.table(
  df,
  trim_stat_out,
  quote = FALSE,
  row.names = FALSE,
  sep = "\t"
)

png(
  paste0(args$out_dir, "trim_stat.png"),
  width = 6,
  height = 4,
  res = 300,
  units = "in"
)

df %>% ggplot(
  aes(x=as.numeric(input_reads), y=remaining_reads_pct, color=dropped_pct, label=samples)
) +
  geom_point() +
  xlab("Input read count") +
  ylab("Remaining reads after trimming (%)") +
  labs(color="Reads dropped (%)") +
  theme_minimal() +
  scale_color_viridis_c(direction = 1, option = "B") +
  ggtitle(
    paste("Statistics of the read trimming | N =", nrow(df)),
    "(each point reprsents a sample)"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

dev.off()

