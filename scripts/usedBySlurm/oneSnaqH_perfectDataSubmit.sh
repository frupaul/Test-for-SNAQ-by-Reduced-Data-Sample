#!/bin/bash
#SBATCH -o perfect_Long_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nji3@wisc.edu
#SBATCH --array=0-239
#SBATCH -p long
export JULIA_PKGDIR="/workspace/nanji/.julia"
echo $(hostname)
/usr/bin/julia /workspace/nanji/oneSnaqH.jl long 3 30 $SLURM_ARRAY_TASK_ID
