## julia script that will take two arguments:
## array_ID: that will be linked to the seed
## hmax
## julia oneSnaqOneRun.jl h ID

unshift!(Base.LOAD_CACHE_PATH, joinpath(Base.LOAD_CACHE_PATH[1], gethostname()))
using PhyloNetworks;

if(isempty(ARGS))
    h = 0
    id = 1
else
    h = ARGS[1]
    id = ARGS[2]
end


tableCF = readTableCF("tableCF.txt");
Filename = "bestStartingTree.tre"; # initialize for hmax=0
startingTree = readTopology(Filename);

srand(1)
for i in 1:id
    s = round(Integer,floor(rand()*100000))
end

rootname =  string("snaq_h",h,"_id_",id)
Filename = string(rootname, ".out")
##Output = snaq!(startingTree, tableCF, hmax = h, runs = 1, filename = rootname);
println(rootname)
