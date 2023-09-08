## Extra note: Rivanna UVA internal

### Account setup
When running slurm jobs, please verify the `Rivanna` account information before starting. `#SBATCH -A <account name>` needs to be updated with accurate account name in each slurm script located in the  `src/slurm`. The default value, `cphg-farber` is only available to the members of the Farber lab.

### Running jobs in interactive mode
UVA users can run above modules interactively on Rivanna using the following code. For more details on slurm job management in UVA HPC systems, see the [UVA Research Compute page](https://www.rc.virginia.edu/userinfo/rivanna/slurm/)

```bash
#!/bin/bash
ijob --account=<account> --nodes=1 --cpus-per-task=16 --partition=largemem --time=48:00:00 bash src/sh/<script name> <arguments>
```