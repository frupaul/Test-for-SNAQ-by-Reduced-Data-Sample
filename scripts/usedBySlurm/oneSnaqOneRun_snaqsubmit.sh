#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nji3@wisc.edu
#SBATCH --array=1-100
#SBATCH -p long
export JULIA_PKGDIR="/workspace/nanji/.julia"
/usr/bin/julia /workspace/nanji/oneSnaqOneRun.jl 1 $SLURM_ARRAY_TASK_ID
