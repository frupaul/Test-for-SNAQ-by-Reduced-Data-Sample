# Simulation study

## Four types of data:

- Perfect CF
- Simulated gene trees
- Estimated gene trees
- Real-life data


## Parameters to vary

- xtolAbs 10-6, 10-3
- xtolRel 10-3, 10-2
- ftolAbs 10-6,10-5,10-4,10-3,10-2
- ftolRel 10-5 (default)
- liktolAbs/ftolAbs 1,100,10000
- Nfail 100,75,50,25

These are 240 combinations for each type of data, each combination will have 100 runs.


## Variables of interest

- Average CPU time per run
- Average loglik per run
- Number of runs correct network found


## Need to write:

- a script that will read a table of CF and will estimate a network, with meaningful names based on parameters
- a script that will read a list of trees and will estimate a network, with meaningful names based on parameters
- a script that will summarize the log and out files for each combination, and that will combine all results into a table


Now we are using SLURM to parallelize the jobs. SLURM can take an array of jobs (1:240) and parallelize them across different computers.
Info [in slurm](http://slurm.schedmd.com/job_array.html), and [in stat](http://www.stat.wisc.edu/services/hpc-cluster),
and [in chicago](https://rcc.uchicago.edu/docs/running-jobs/array/index.html)

We need to be careful because we want to start all jobs in the same tree and network. That is, all job for hmax=1 across all 240 scenarios should have the same starting tree, otherwise, differences in performance can be due to different starting trees, not differences in parameters.

### Perfect Data

So, the preliminary 30 runs with default parameters are run with `scripts/useForSlurm/oneSnaqOneRun_snaqsubmit.sh`, that calls
`oneSnaqOneRun.jl` that takes two input arguments: `h` and `$SLURM_ARRAY_TASK_ID` that will represent the run.
Slurm will then parallelize all the runs.

Then, we can use the script `scrips/useforSlurm/findBestModel.jl` to find the best topology among all the `.out` files for all
the 50 runs. Let's write these topologies into files: `h1bestStartingTree.tre, h2bestStartingTree.tre, h3bestStartingTree.tre`.

Now, we need to create a julia script that will use `h3bestStartingTree.tre` as starting topology and run snaq for `h=3`: `oneSnaqH.jl` that takes 3 arguments: `h,runs,job_array`.
According to preliminary runs, one runs takes roughly 7 hours, so we will start with 30 runs first that will roughly take 9 days.
We will use slurm to parallelize all 240 scenarios (slurm has 288 cores). The SLURM script is `oneSnaqH_snaqsubmit.sh`.

Now, Nan is working on functions to summarize the results after the runs are finished. Code will be inspired by scripts [here](https://github.com/zhou325/stat679work/tree/master/hw1)

Summary functions are in the folder `scripts/infoGenerator/`.

The functions used to run the perfect data are `oneSnaqH_perfectDatasubmit.sh` which calls `oneSnaqH.jl`. All runs are in `marzano` which have comparable running times.
We did not run in `darwin` machines, because we cannot control using only `darwin02-06`, and not all `darwin` machines have comparable speed (only 02-06).

`Slurm` has a limit of 48 nodes per user (24 if using R or julia). Mike C. has mentioned that he can remove this restriction for future analyses so that Nan can use 96 nodes. Mike C. also has plans to create a specific partition for `darwin02-06`.

Action items:

1. Write a shell script to rename all log and out file from the 60 prior runs: add “marzano” to these file names. Also perhaps add “perfect” to refer to the input data for these runs.

Nan: please document the shell commands / shell script that you used for this, and add text in your readme file to document this change in file names. You have an example of a script by Youjia Zhou [here](https://github.com/zhou325/stat679work/tree/master/hw1)
in her script to change file names. copied below.

```shell
for i in {1..9}
do
mv hw1-snaqTimeTests/log/timetest${i}_snaq.log hw1-snaqTimeTests/log/timetest0${i}_snaq.log
mv hw1-snaqTimeTests/out/timetest${i}_snaq.out hw1-snaqTimeTests/out/timetest0${i}_snaq.out
done
```

2. Wait for the remaining runs for perfect data (should be finished within a week).

3. Run all combinations for the data from estimated trees on 300 genes. It looks like these [data](https://github.com/frupaul/Test-for-SNAQ-by-Reduced-Data-Sample/blob/master/data/est300GeneTrees_n15/1_seqgen.CFs.csv)
The same starting networks could be used as for the perfect data. These runs will use also `marzano`, instead of waiting for Mike to have the new partition for `darwin02-06`.
