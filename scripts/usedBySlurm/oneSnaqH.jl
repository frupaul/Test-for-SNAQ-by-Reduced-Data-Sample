# Julia script to run SNaQ! on a test data set with 4 input parameters:
# The name of the dataset sent to
# - a number of hybridizations
# - a number of total runs
# - a integer representing the ID number of one specific combination of parameters for each slurm task

# Read the 4 input parameters for this Julia script.
# If the user did not input all three parameters,
# The name of the dataset will be default to be long,
# the hybridization number will be default to be 0,
# number of runs will defaultly be set as 1,
# and the id number will be 0.

if(length(ARGS)<3)
    dataset = "perfect";
    h = 0;
    Runs = 1;
    id = 0;
else
    partition = ARGS[1];
    h = parse(Int, ARGS[2]);
    Runs = parse(Int, ARGS[3]);
    id = parse(Int, ARGS[4]);
end

using PhyloNetworks; # package contains the function snaq!

# lists of all possible varied values for each parameter:
lXTA = [0.000001, 0.001];
lXTR = [0.001, 0.01];
lFTA = [0.000001, 0.00001, 0.0001, 0.001, 0.01];
lRatio = [1, 100, 10000];  # controld LTA: Ratio=LTA/FTA
lNF = [100,75,50,25];

# 5 parameters, with 5*4*3*2*2 = 240 combinations in total
nparams = 5
nlevels = [length(lFTA),length(lNF),length(lRatio),length(lXTR),length(lXTA)]

FTR = 0.00001; # the parameter set to be a fixed value

"""
comb(index of parameter combination)

Take an integer as input, return a tuple of parameter values.
External objects are used: nparams, nlevels, and lFTA etc.
The integer input should be between 0 and 239, or
between 0 and the total # combinations -1 in general.
index 0 -> first values of all parameters
index 239 -> last values of all parameters
"""
function comb(combID)
  paramID = Vector{Int}(nparams)
  d = combID
  for par in 1:nparams
    d,r = fldmod(d, nlevels[par]) # combid = d * nlevels + r
    paramID[par] = r+1 # indexing in parameter list starts at 1, not 0
  end
  println("parameter levels: ",paramID)
  return lFTA[paramID[1]], lNF[paramID[2]], lRatio[paramID[3]], lXTR[paramID[4]], lXTA[paramID[5]]
end

FTA, NF, Ratio, XTR, XTA = comb(id)
LTA = FTA*Ratio;

    if dataset == "perfect"

        partition = "Marzano";
        scalar = 1;
        tableCF = readTableCF("tableCF.txt");# read the input CFtable file

    elseif dataset == "est300"

        partition = "darwin";
        scalar = 2;
        tableCF = readTableCF("1_seqgen.CFs.csv");

    end

    # set the name of the out file of snaq!
    # this name includes all the information of the input parameters for snaq!

    rootname = string(partition,"_",dataset,"_snaq_hmax",h,"nf",NF,"xta",
                      XTA,"xtr",XTR,"fta",FTA,"ftr",FTR,"lta",LTA,"_",gethostname());

    Filename = string("h",h,"BestStartingTree.out"); # the name of starting tree model selected by findBestModel.jl
    startingTree = readTopology(Filename); # read the starting tree model

    # Set the seed to generate random numbers to make all the results reproducible,
    # or to restart the process if some fail.

    srand(scalar*(h+1));
    for i in 0:id
      global s = round(Integer,floor(rand()*100000)); # seed will be used in the snaq! function
    end

    # To find if the combination of the parameters has already be done,
    # so that user could prevent the repeat running.

    rootnameLog = string(rootname,".log");

    if isfile(rootnameLog) && filesize(rootnameLog)>1000

        print(rootname," Combination exists.");

    else

        Output = snaq!(startingTree, tableCF, hmax = h, Nfail = NF,
                   ftolAbs = FTA, ftolRel = FTR, xtolRel = XTR,
                   xtolAbs = XTA, liktolAbs = LTA,
                   runs = Runs, seed = s, filename = rootname);
    end


