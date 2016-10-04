using PhyloNetworks;
tableCF = readTableCF("tableCF.txt");
startingTree = readTopology("bestStartingTree.txt");
Filename =  string("nf",100,"xta",1e-05,"xtr",0.001,"fta",1e-06,"ftr",1e-05,"lta",1e-06,"_snaq");
Output = snaq!(startingTree, tableCF, Nfail = 100,
ftolAbs = 1e-06, xtolRel = 0.001, xtolAbs = 1e-05, liktolAbs = 1e-06, runs = 10, filename = Filename);
