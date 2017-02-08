
# Read the 2 input parameters for the Julia script.
# If the user did not input two parameters,
# The hybridization number will be default to be 0,
# number of runs will defaultly be set as 1,
# so that it will match the default input for oneSnaqH.jl

if length(ARGS)<2
    h = 0;
    runs = 1;
else
    h = ARGS[1];
    runs = ARGS[2];
end

using PhyloNetworks; # package contains the function readTopology.

# the function will be used to read the line containing
# the loglikelihood value and return the numeric value.

function eachRunLoglik(x)
    a = split(x);
    b  = parse(Float64, a[end]);
    return b
end

# in the for loop, the log-like value of each snaq.out file
# will be compared one by one and the smaller log-like value
# will be recorded everytime until we find the smallest one
# and return the id of that topology.

for i = 1:runs
    Filename =  string("snaq_h",h,"_id_",i,"_snaq.out");
    file = open(Filename); # read the content of a new file
    lines = readlines(file);
    logLike = eachRunLoglik(lines[1]);
    if i = 1
        a = logLike; # set a starting value of a
        b = 1; # set a starting value of b
    end
    if (logLike < a)
        a = logLike;
        b = i; # b records the id of the topology with smaller log-lik value
    end
    file = close(file); # close this file
end

findTree = string("snaq_h",h,"_id_",b,"_snaq.out"); # set name for the chosen topology with smallest log-like
Tree = readTopology(findTree); # read this topology
fileName = string("h",h+1,"BestStartingTree.out"); # name of the out file which saves this topology

open(fileName, "w") do f
    write(fileName, Tree) # save the topology into a new out file as the input file for oneSanqOneRun.jl or oneSnaqH.jl
end

