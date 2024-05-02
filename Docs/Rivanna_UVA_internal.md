## Extra note: Rivanna UVA internal

### Account setup
When running slurm jobs, please verify the `Rivanna` account information before starting. `#SBATCH -A <account name>` needs to be updated with accurate account name in each slurm script located in the  `src/slurm`. The default value, `cphg-farber` is only available to the members of the Farber lab.

### Dependencies

All necessary packages (dependencies) are prebuilt in Rivanna. To use these packages use the `module command`.

```bash
#!/bin/bash
# check all necessary modules to be loaded for a package
module spider <package>/<version>
#load a module
module load <package>/<version>
```

Note: In some instances, the exact version of the module used originally, is no longer available in Rivanna. The older versions have been replaced with a newer version of the same software. If some errors arise due to the version issue, the user should check the available module using the `module avail <module name>` command and modify the slurm scripts to include the available version.

### Running jobs in interactive mode
UVA users can run above modules interactively on Rivanna using the following code. For more details on slurm job management in UVA HPC systems, see the [UVA Research Compute page](https://www.rc.virginia.edu/userinfo/rivanna/slurm/)

```bash
#!/bin/bash
ijob --account=<account> --nodes=1 --cpus-per-task=16 --partition=largemem --time=48:00:00 bash src/sh/<script name> <arguments>
```

