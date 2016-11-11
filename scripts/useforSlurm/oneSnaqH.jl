##unshift!(Base.LOAD_CACHE_PATH, joinpath(Base.LOAD_CACHE_PATH[1], gethostname()))
using PhyloNetworks;
include("comboGenerator.jl");

eXTA = [0.000001, 0.001];
dXTR = [0.001, 0.01];
aFTA = [0.000001, 0.00001, 0.0001, 0.001, 0.01];
cRatio = [1, 100, 10000];
bNF = [100,75,50,25];
XTA = 0.000001;
XTR = 0.001;
FTA = 0.000001;
FTR = 0.00001;
Ratio = 1;
NF = 100;

if(isempty(ARGS))
    h = 0;
    Runs = 1;
    id = 0;
else
    h = parse(Int, ARGS[1]);
    Runs = parse(Int, ARGS[2]);
    id = parse(Int, ARGS[3]);
    cob = comb(id);
    XTA = eXTA[cob[1]];
    XTR = dXTR[cob[2]];
    FTA = aFTA[cob[3]];
    FTR = 0.00001;
    Ratio = cRatio[cob[4]];
    NF = bNF[cob[5]];
end

    tableCF = readTableCF("tableCF.txt");
    Filename = string("h",h,"BestStartingTree.out");
    startingTree = readTopology(Filename);

    LTA = FTA*Ratio;

    idd = id + 1;
    srand(h+1);
    s = 1;
    for i in 1:idd
        s = round(Integer,floor(rand()*100000));
    end

    rootname =  string("slurm_hmax",h,"nf",NF,"xta",XTA,"xtr",XTR,"fta",FTA,"ftr",FTR,"lta",LTA,"_snaq");
    Output = snaq!(startingTree, tableCF, hmax = h, Nfail = NF,
                   ftolAbs = FTA, ftolRel = FTR, xtolRel = XTR,
                   xtolAbs = XTA, liktolAbs = LTA,
                   runs = Runs, seed = s, filename = rootname);

