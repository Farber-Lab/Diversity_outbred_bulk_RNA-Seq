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