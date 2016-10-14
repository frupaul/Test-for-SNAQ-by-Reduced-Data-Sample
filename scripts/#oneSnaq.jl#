## to run in terminal:
## julia oneSnaq.jl xta xtr fta ftr ratio nf runs
## e.g. julia oneSnaq.jl 0.000001 0.001 0.000001 0.00001 1 100 2
## the parameters need to be in the exact order, and all parameters
## need to be specified

using PhyloNetworks;

tableCF = readTableCF("tableCF.txt");
startingTree = readTopology("bestStartingTree.txt");

if(isempty(ARGS))
    XTA = 0.000001
    XTR = 0.001
    FTA = 0.000001
    FTR = 0.00001
    Ratio = 1
    NF = 100
    Runs = 2
else
    XTA = ARGS[1]
    XTR = ARGS[2]
    FTA = ARGS[3]
    FTR = ARGS[4]
    Ratio = ARGS[5]
    NF = ARGS[6]
    Runs = ARGS[7]
end

LTA = FTA*Ratio;

Filename =  string("nf",NF,"xta",XTA,"xtr",XTR,"fta",FTA,"ftr",FTR,"lta",LTA,"_snaq");
Output = snaq!(startingTree, tableCF, Nfail = NF,
               ftolAbs = FTA, ftolRel = FTR, xtolRel = XTR,
               xtolAbs = XTA, liktolAbs = LTA,
               runs = Runs, filename = Filename);
