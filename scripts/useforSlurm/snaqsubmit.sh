#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nji3@wisc.edu
#SBATCH --array=1-50
export JULIA_PKGDIR="/workspace/nanji/.julia"
/workspace/software/julia-0.5.0/julia /workspace/nanji/oneSnaqOneRun.jl 0 $SLURM_ARRAY_TASK_ID 
