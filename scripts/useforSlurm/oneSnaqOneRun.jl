## julia script that will take two arguments:
## array_ID: that will be linked to the seed
## hmax
## julia oneSnaqOneRun.jl h ID

if(length(ARGS)<2)
    h = 0
    id = 1
else
    h = parse(Int, ARGS[1]);
    id = parse(Int, ARGS[2]);
end

using PhyloNetworks # the package contains the function snaq!

tableCF = readTableCF("tableCF.txt");
Filename = string("h",h+1,"BestStartingTree.out") # initialize for hmax=0
startingTree = readTopology(Filename);

srand(h+10); ##set seed
for i in 0:id
    global s = round(Integer,floor(rand()*100000)) # seed will be used in the snaq! function
end

rootname =  string("snaq_h",h,"_id_",id)
##Filename = string(rootname, ".out")
Output = snaq!(startingTree, tableCF, hmax = h, runs = 1, seed = s, filename = rootname);
##println(rootname)
