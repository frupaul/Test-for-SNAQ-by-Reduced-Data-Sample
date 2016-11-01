unshift!(Base.LOAD_CACHE_PATH, joinpath(Base.LOAD_CACHE_PATH[1], gethostname()))
using PhyloNetworks;
include("comboGenerator.jl");
cd("/afs/cs.wisc.edu/u/n/a/nanji/parameterTest");

tableCF = readTableCF("tableCF.txt");
Filename = "bestStartingTree.tre"; # initialize for hmax=0
eXTA = [0.000001, 0.001];
dXTR = [0.001, 0.01];
aFTA = [0.000001, 0.00001, 0.0001, 0.001, 0.01];
cRatio = [1, 100, 10000];
bNF = [100,75,50,25];

if(isempty(ARGS))
    XTA = 0.000001;
    XTR = 0.001;
    FTA = 0.000001;
    FTR = 0.00001;
    Ratio = 1;
    NF = 100;
    Runs = 1;
    Hmax = 3;
else
    comb = comb(ARGS[1]);
    XTA = eXTA[comb[1]];
    XTR = dXTR[comb[2]];
    FTA = aFTA[comb[3]];
    FTR = 0.00001;
    Ratio = cRatio[comb[4]];
    NF = bNF[comb[5]];
    Runs = 1;
    Hmax = 3;
end

LTA = FTA*Ratio;

for i = 0:Hmax
    startingTree = readTopology(Filename);
    rootname =  string("nf",NF,"xta",XTA,"xtr",XTR,"fta",FTA,"ftr",FTR,"lta",LTA,"hmax",i,"_snaq");
    Filename = string(rootname, ".out")
    Output = snaq!(startingTree, tableCF, hmax = i, Nfail = NF,
                   ftolAbs = FTA, ftolRel = FTR, xtolRel = XTR,
                   xtolAbs = XTA, liktolAbs = LTA,
                   runs = Runs, filename = rootname);
end
