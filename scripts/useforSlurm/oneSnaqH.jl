# Julia script to run SNaQ! on a test data set with 3 input parameters:
# - a number of hybridizations
# - a number of total runs
# - a integer representing the ID number of one specific combination of parameters for each slurm task

# Read the 3 input parameters for this Julia script.
# If the user did not input all three parameters,
# The hybridization number will be default to be 0,
# number of runs will defaultly be set as 1,
# and the id number will be 0.

if(length(ARGS)<3)
    h = 0;
    Runs = 1;
    id = 0;
else
    h = parse(Int, ARGS[1]);
    Runs = parse(Int, ARGS[2]);
    id = parse(Int, ARGS[3]);
end

using PhyloNetworks; # package contains the function snaq!

# lists of all possible varied values for each parameter:
eXTA = [0.000001, 0.001];
dXTR = [0.001, 0.01];
aFTA = [0.000001, 0.00001, 0.0001, 0.001, 0.01];
cRatio = [1, 100, 10000];
bNF = [100,75,50,25];
# 5 parameters, with 5*4*3*2*2 = 240 combinations in total

FTR = 0.00001; # the parameter set to be a fixed value

# Include a julia script from outside containing one function comb() inside.
# The function comb(ID number of a specific parameter combination).
# This function takes a integer as input and returns a array of the parameter values.
# The integer input should be between 0 and 239.
# Index 0 is the first values of all parameters,
# Index 239 is the last values of all parameters.

include("comboGenerator.jl");

cob = comb(id); #read the array of specific combination of parameters
XTA = eXTA[cob[1]];
XTR = dXTR[cob[2]];
FTA = aFTA[cob[3]];
Ratio = cRatio[cob[4]];
NF = bNF[cob[5]];
LTA = FTA*Ratio;

    tableCF = readTableCF("tableCF.txt"); # read the input CFtable file
    Filename = string("h",h,"BestStartingTree.out"); # the name of starting tree model selected by findBestModel.jl
    startingTree = readTopology(Filename); # read the starting tree model

    # Set the seed to generate random numbers to make all the results reproducible,
    # or to restart the process if some fail.
    srand(h+1);
    for i in 0:id
      global s = round(Integer,floor(rand()*100000)); # seed will be used in the snaq! function
    end

    # set the name of the out file of snaq!
    # this name includes all the information of the input parameters for snaq!
    rootname =  string("slurm_hmax",h,"nf",NF,"xta",XTA,"xtr",XTR,"fta",FTA,"ftr",FTR,"lta",LTA,"_snaq");
    Output = snaq!(startingTree, tableCF, hmax = h, Nfail = NF,
                   ftolAbs = FTA, ftolRel = FTR, xtolRel = XTR,
                   xtolAbs = XTA, liktolAbs = LTA,
                   runs = Runs, seed = s, filename = rootname);

