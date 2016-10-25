#!/binbash
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nji3@wisc.edu
alias julia="/workspace/software/julia-0.5.0/julia"
export JULIA_PKGDIR="/workspace/nanji/.julia"
julia oneSnaqSlurm.jl
