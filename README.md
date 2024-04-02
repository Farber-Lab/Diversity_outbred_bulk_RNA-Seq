# Diversity Outbred (DO) bulk RNA-Seq pipeline

## Getting started

Clone this repository in your computing environment

```bash
#!/usr/bin/bash
# make sure git is set up to handle SSH login
git clone git@github.com:Farber-Lab/Diversity_outbred_bulk_RNA-Seq.git
cd Diversity_outbred_bulk_RNA-Seq/
```
---
Note: **GitHub no longer supports password authentication on `https://` URLs**. SSH login methods are preferred. To setup SSH based login please follow this [documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account). Alternatively, a token can be used for authentication. Use [GitHub settings](https://github.com/settings/tokens) to generate a token.


### Core Dependencies

The following dependencies should be installed in the computing environment and available in the `$PATH`

#### Genomics utilities
* fastqc/0.11.5
* multiqc/1.11
* trimmomatic/0.39
* hisat2/2.1.0
* Samtools/1.12
* stringtie/2.1.0
* peer/1.3

#### Language interpreters
* python/2.7.16
* python/3.8.8
* R/4.2.1


## Documentation

* [Modules used in this workflow](Docs/modules.md)
* [Notes for Rivanna Users (UVA internal)](Docs/Rivanna_UVA_internal.md)
