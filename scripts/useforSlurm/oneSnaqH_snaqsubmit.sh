#!/bin/bash
#SBATCH -o 240combo%a.out
#SBATCH --nodelist=darwin0[2-6]
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nji3@wisc.edu
#SBATCH --array=0-239
#SBATCH -p darwin
export JULIA_PKGDIR="/workspace/nanji/.julia"
echo $(hostname)
/usr/bin/julia /workspace/nanji/oneSnaqH.jl 3 30 $SLURM_ARRAY_TASK_ID
