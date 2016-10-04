#Some Instructions about how to run the script file.

Pkg.add("PhyloNetworks");
Pkg.build("PhyloNetworks");
Pkg.update();
using PhyloNetworks;

cd("$(homedir())/Desktop/Research/2016fall/parameterTest/data/true300GeneTrees_n6");
D = readTableCF("tableCFall.txt");
startingTree = readTopology("11_astral.out");
XTA = [0.000001, 0.001];
XTR = [0.001, 0.01];
FTA = [0.000001, 0.00001, 0.0001, 0.001, 0.01];
FTR = 0.00001;
Ratio = [1, 100, 10000];
NF = [100,75,50,25];
Runs = 2;

for a = XTA[1:end]
    for b = XTR[1:end]
        for c = NF[1:end]
            for d = Ratio[1:end]
                for e = FTA[1:end]
                    LTA = d*e;
                    Filename =  string("N6nf",c,"xta",a,"xtr",b,"fta",e,"ftr",FTR,"lta",LTA,"_snaq");
                    Output = snaq!(startingTree, D, Nfail = c,
                                   ftolAbs = e, xtolRel = b,
                                   xtolAbs = a, liktolAbs = LTA,
                                   runs = Runs, filename = Filename);
                end
            end
        end
    end
end


