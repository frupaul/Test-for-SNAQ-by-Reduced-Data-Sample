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

`Slurm` has a limit of 48 nodes per user (24 if using R or julia). Mike C. has mentioned that he can remove this restriction for future analyses so that Nan can use 96 nodes. Mike C. also has plans to create a specific partition for `darwin02-06`. Mike C. did this already, and `#SBATCH -p darwin` uses only `darwin02-06`.

This has been done already by Nan:

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

3. Run all combinations for the data from estimated trees on 300 genes. It looks like these [data](https://github.com/frupaul/Test-for-SNAQ-by-Reduced-Data-Sample/blob/master/data/est300GeneTrees_n15/1_seqgen.CFs.csv)
The same starting networks could be used as for the perfect data. These runs will use `darwin02-06`. Make the names of scripts match the dataset.
Also, keep in mind Mike's option:
`#SBATCH --qos unlimitedcpu`


4. **Debug** Create folder with input files and commands to reproduce bugs!!

## Summary of results

We get a table with one row per scenario, and different columns like median loglik, number of runs (out of 30) that estimate the true topology, median time, and accuracy (probability of having at least one successful run out of the 10 default runs).

Nan will write some scripts for some plots, and will try to publish as html with labels to the points. In particular, we want to see a plot of time vs accuracy (with points with different color based on `Nfail`, or other arguments). We can also sort the table by accuracy, and identify the scenarios with high accuracy and lower time.

We want to compare the results between perfect and estimated data.

Ultimately, it would be nice to have a table in the SNaQ documentation with a few scenarios (one row per scenario, first row default parameters), and the parameters as columns, along with two measures: time and accuracy (as above described). In each scenario, we can write the reduction in time and accuracy compared to the default. This will allow users to choose parameters.

Action items:

1. Create a README file with information on the scripts to summarize the output files (in julia and R), add the scripts to produce the plots

3. Create a table comparing the default to other good combinations that reduce time, and don't reduce accuracy (or only slightly)

4. Warning with likTolAbs? likTolAbs=100 does not make sense

5. Select a few good combinations (10 or so?), candidates for the new default.
   These combinations could be tested more thoroughly (more than 30 runs), and on a
   different data set, to narrow down the choice to a single best combination that
   will be used as the new default.

Sub-action items to complete item 3 above (3/17):

- check files on estimated gene trees, that have the correct topology but poor score,
  and check files / runs that got a bad topology but excellent score.
- change the criterion to measure accuracy: instead of using "correct topology", use "score below x".
  x=555 looks like a good choice for the estimated gene trees.
  A "good run" would be a run whose score below x.
- run multiple logistic regression on y=1 (good run) or 0 (not a good run).
  exclude Nfail=25 and exclude liktolAbs=100 for this analysis.
  use the data set that has 1 row per run.
  Do not include any interaction terms first, to "smooth" the results.
- run multi-way ANOVA on y = mean time, also using the data set that has 1 row per run
  (to get an estimate of variance in CPU time between runs within the same combination).

## Some results after meeting (3/31/2017)
Nan studied the runs that had loglik below a certain threshold, and whether those runs coincided with having the true topology.
- For estimated data, the runs with loglik<=500 all have the true topology, the runs with loglik<=555, 89% have the true topology. Actually, 97% of runs with the true topology have loglik<=555.
- For perfect data, the runs with loglik<=5, all have the true topology; runs with loglik<=10, 93% have the true topology. Actually, 94% of the runs with the true topology have a loglik<=10

**Questions**
- Do we still want to change the definition of "good run": score below x, or keep correct topology?
Yes, we want to identify a "good run" as a run in which the correct topology would be selected as the estimated topology. For perfect data, this seems to be the case with loglik<8. For estimated data, it seems that it will be with loglik<500.

### Logistic regression results
- Using now, "good run"= correct topology. Excluding Nfail=25,and likTolAbs=100.

Perfect data:
```
Call:
glm(formula = TrueTopo ~ Nfail + FtolAbs + XtolAbs + XtolRel +
    LiktolAbs, family = "binomial", data = info)

Deviance Residuals:
    Min       1Q   Median       3Q      Max  
-1.0537  -0.9021  -0.7813   1.3666   1.9594  

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept) -1.327e+00  1.298e-01 -10.224  < 2e-16 ***
Nfail        1.038e-02  1.516e-03   6.849 7.46e-12 ***
FtolAbs     -5.791e+01  9.790e+00  -5.915 3.33e-09 ***
XtolAbs     -1.293e+02  6.167e+01  -2.096   0.0361 *  
XtolRel     -9.297e+00  6.844e+00  -1.358   0.1743    
LiktolAbs   -6.730e-02  1.365e-02  -4.930 8.22e-07 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 6244.8  on 5037  degrees of freedom
Residual deviance: 6126.5  on 5032  degrees of freedom
AIC: 6138.5

Number of Fisher Scoring iterations: 4
```

Estimated data:
```
Call:
glm(formula = TrueTopo ~ Nfail + FtolAbs + XtolAbs + XtolRel +
    LiktolAbs, family = "binomial", data = info)

Deviance Residuals:
    Min       1Q   Median       3Q      Max  
-0.9385  -0.8517  -0.7735   1.4507   1.7725  

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept)  -1.490121   0.131914 -11.296  < 2e-16 ***
Nfail         0.008676   0.001532   5.664 1.48e-08 ***
FtolAbs     -18.820774   9.361006  -2.011   0.0444 *  
XtolAbs     -96.435490  62.373412  -1.546   0.1221    
XtolRel       3.089989   6.922120   0.446   0.6553    
LiktolAbs     0.001557   0.012129   0.128   0.8979    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 6073.3  on 5038  degrees of freedom
Residual deviance: 6034.3  on 5033  degrees of freedom
AIC: 6046.3

Number of Fisher Scoring iterations: 4
```
Overall, it seems that `Nfail` and `ftolAbs` are variables that affect the performance of a snaq run.

- Now we use a different definition of "good run". For perfect data, a "good run" is a run that has loglik<=8 (loglik<=30 for a "relatively good run"), and for estimated data, a "good run" is a run that has a loglik<=500 (loglik<=550 for a "relatively good run").

- **Next steps:** Do a multi-way ANOVA on y = mean time, also using the data set that has 1 row per run
  (to get an estimate of variance in CPU time between runs within the same combination).
