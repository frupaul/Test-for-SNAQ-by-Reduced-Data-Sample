#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nji3@wisc.edu
#SBATCH --array=1-240
export PERL5LIB="/s/slurm/lib/perl/5.18.2"
export JULIA_PKGDIR="/workspace/nanji/.julia"
/workspace/software/julia-0.5.0/julia /workspace/nanji/oneSnaqH.jl 3 30 $SLURM_ARRAY_TASK_ID 
