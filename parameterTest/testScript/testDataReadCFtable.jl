#Some Instructions about how to run the script file.

Pkg.add("PhyloNetworks");
Pkg.build("PhyloNetworks");
Pkg.update();
using PhyloNetworks;

cd("$(homedir())/Desktop/Research/2016fall/parameterTest/data/testdata");
tableCF = readTableCF("tableCF.txt");
startingTree = readTopology("bestStartingTree.txt");
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
                    Filename =  string("nf",c,"xta",a,"xtr",b,"fta",e,"ftr",FTR,"lta",LTA,"_snaq");
                    Output = snaq!(startingTree, tableCF, Nfail = c,
                                   ftolAbs = e, xtolRel = b,
                                   xtolAbs = a, liktolAbs = LTA,
                                   runs = Runs, filename = Filename);
                end
            end
        end
    end
end

#filename = string("xta", XTA, "xtr", XTR)

#liktolAbs #loop for Ratio and ftolAbs to find all liktolAbs. liktolAbs could be anything but here we just want to fix the Ratio.

#Use grep in Julia and save the specific line into a string and use string[end] to find the loglik number and convert it to numbers.

#use Date Pkg to do compute the time for each run
#DateTime Pkg
#dat1 = Dates.DataTime("Thu Jun 16 21:41:50 2016", "e u dd HH:MM:SS yyyy")
#dat2 - dat1
#Transfer them to minutes Int(dat2 - dat1)/(60*1000)
#readTree = readTree2CF("treeList.tre");
