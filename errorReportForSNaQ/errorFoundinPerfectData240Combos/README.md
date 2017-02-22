# Error Report

When running 240 combinations of parameters for the perfect data, there appears an error.
The error warnings exist in three combinations log files. Each log file has one
error warning. 

In `parameterTest/perfectData240comboLogfile`, run code

```shell
grep -e "Error" parameterTest/perfectData240comboLogfile/*.log
```

It will show the errors.
1. `Marzano_perfect_slurm_hmax3nf100xta1.0e-6xtr0.001fta0.001ftr1.0e-5lta0.1_snaq.log`:
`ERROR found on SNaQ for run 6 seed 35974: BoundsError([0.220203,0.00415994,0.0,
0.834263,1.02728,1.62602,0.77724,1.50746,1.10232,0.866303,1.96202e-5,1.73777,
0.651659,1.21344,0.771748,1.11946,1.78812,0.287995,0.0,0.908797],(4:22,))`

2. `Marzano_perfect_slurm_hmax3nf25xta0.001xtr0.001fta1.0e-6ftr1.0e-5lta9.999999999999999e-5_snaq.log`:
`ERROR found on SNaQ for run 18 seed 20500: ErrorException("major hybrid edge 35 
has gamma less than 0.5: 0.49999999999999994")`

3. `Marzano_perfect_slurm_hmax3nf50xta0.001xtr0.01fta1.0e-5ftr1.0e-5lta0.001_snaq.log`:
`ERROR found on SNaQ for run 4 seed 72042: ErrorException("edge 36 gamma 
1.6005697326353133e-6 should match the gamma in net.ht 
6.4022789305412525e-6 and it does not")`

This might mean that there is still a bug in SNaQ.

To reproduce the error, we will use the starting tree topology `errorReportForSNaQ/errorFoundinPerfectData240Combos/h3BestStartingTree.out`, and the CF table `tableCF.txt`.

The following code will be used.

```julia
using PhyloNetworks;
cd("$(homedir())/Test-for-SNAQ-by-Reduced-Data-Sample/errorReportForSNaQ/errorFoundinPerfectData240Combos/");

Nf = [100,25,50];
XTA = [0.000001,0.001,0.001];
XTR = [0.001,0.001,0.01];
FTA = [0.001,0.000001,0.00001];
FTR = [0.00001,0.00001,0.00001];
LTA = [0.1,9.999999999999999e-5,0.001];
s = [35974,20500,72042];
tableCF = readTableCF("tableCF.txt");
startingTree = readTopology("h3BestStartingTree.out");

for i in 1:3 
    rootname = string(Error,"_perfectData_snaq_hmax3","nf",NF[i],"xta",
                        XTA[i],"xtr",XTR[i],"fta",FTA[i],"ftr",FTR[i],"lta",LTA[i]);
    Output = snaq!(startingTree, tableCF, hmax = 3, Nfail = NF[i],
        ftolAbs = FTA[i], ftolRel = FTR[i], xtolRel = XTR[i],
        xtolAbs = XTA[i], liktolAbs = LTA[i],
        runs = 1, seed = s[i], filename = rootname);
end
```