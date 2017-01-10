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

New SNaQ runs: Cecile and Nan talked about 2 issues:

1. Nan was unable to submit to the darwin partition. This can be fixed by changing the path to Julia and re-compiling the packages in `/workspace/nanji/.julia`. The path to julia should be `/usr/bin/julia`
which redirects to `/worskpace/software/julia-0.5.0-1/bin/julia`, recently build by Mike for darwin machines.
We checked, and this path seems to work to submit julia jobs to marzano machines as well

2. we are interested in running times, but the running time is affected by the machine!! So the time results obtained on marzano machines are not comparable to the times obtained on darwin machines. All darwin machines are not comparable either. darwin02-06 have identical processors (darwin02 has twice as much RAM than darwin03-06), so we can get comparable running times if we restrict the jobs to darwin02-06. That’s 5 machines * 24 cores * 2 threads = 240 threads total.

Action items:

1. Add the machine name to the log and out files. For this: modify the Julia script (`onesnaqH.jl`) on line 74, and add `gethostname()` in the definition of the output name: `rootname`.

Nan: also, I think it would be a good idea to change this file name to start with “perfect data”, because the plan is to re-run the same script again later with simulated data. My suggestion is to move this line 61:
```julia
tableCF = readTableCF("tableCF.txt"); # read the input CFtable file
```
down below, just before this line 74:
```julia
rootname = string("slurm_hmax",h,"nf",NF,"xta",XTA,"xtr",XTR,"fta",FTA,"ftr",FTR,"lta",LTA,"_snaq”);
```
and change both lines to this:
```julia
dataset = “perfect” # this can be changed later to “estimated300genes"
if dataset == “perfect”
  tableCF = readTableCF("tableCF.txt”);
elseif dataset == “estimated300genes"
tableCF = readTableCF(“1_seqgen.CFs.csv”);
end
rootname = string(dataset,
“_snaq_hmax",h,"nf",NF,
"xta",XTA,"xtr",XTR,"fta",FTA,"ftr",FTR,"lta",LTA,
“_”,gethostname());
```

2. Write a shell script to rename all log and out file from the 60 prior runs: add “marzano” to these file names. Also perhaps add “perfect” to refer to the input data for these runs.

Nan: please document the shell commands / shell script that you used for this, and add text in your readme file to document this change in file names. You have an example of a script by Youjia Zhou [here](https://github.com/zhou325/stat679work/tree/master/hw1)
in her script to change file names. copied below.

```shell
for i in {1..9}
do
mv hw1-snaqTimeTests/log/timetest${i}_snaq.log hw1-snaqTimeTests/log/timetest0${i}_snaq.log
mv hw1-snaqTimeTests/out/timetest${i}_snaq.out hw1-snaqTimeTests/out/timetest0${i}_snaq.out
done
```

3. Also add `echo $(hostname)` to the slurm script

4. Add an “nodelist” option to the slurm script:
`#SBATCH --nodelist=darwin0[2-6]` to restrict slurm to use those 5 machines only.

5. Add `%a` in the name of the slurm output file, in the `#SBATCH -o option`, to get the task array ID in this file. I don’t know how to add the hostname to the name of this output file. Perhaps add “darwin” at least, like this:
`#SBATCH -o perfect_darwin_%a.out`

6. Keep the line about PERL5LIB and tell Mike that removing this line causes emails to have no content.

7. Re-run all combinations on darwin02-06 for the perfect data.

8. Possibly run all combinations again, if there is time before the end of the break,
but for the data from estimated trees on 300 genes. It looks like these [data](https://github.com/frupaul/Test-for-SNAQ-by-Reduced-Data-Sample/blob/master/data/est300GeneTrees_n15/1_seqgen.CFs.csv)
The same starting networks could be used as for the perfect data, I think.

One thing from Nan's email:
Here is a thing. Actually in Slurm, Mike has set a limit for the access of the cores each person can use and it is 48. And for specific jobs, they may not access all the processors (1 cpu with 2 processors and it will work as two cores we need), so jobs may only access 24 cores. Before the winter break, professor and I modified the code and hope them run well in Darwin02-06 because in Darwin02-06, the speeds are the same. However, Mike told me that it would be so hard to split the specific nodes to run the full access of 48 cores. Mike and I talked about it for a while and he said he would try to find way to open the unlimited access for me in Darwin. However, it will still be very hard to specify the nodes and Mike said I should just let Slurm to choose the nodes to prevent any problems.
So now based on the 60 results we've already had, I decided to still run jobs in Marzano (in partition long) first. So that at least I'm not wasting the time and still could have some results. Though it may take more time, during this time, I will still talk with Mike to see if there will be a better way.
