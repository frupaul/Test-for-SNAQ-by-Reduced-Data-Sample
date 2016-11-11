using PhyloNetworks;

function eachRunLoglik(x)
    a = split(x);
    b  = parse(Float64, a[end]);
    return b
end

h = ARGS[1];
runs = ARGS[2];

file = open(string("snaq_h",h,"_id_1_snaq.out"));
lines = readlines(file);
a = eachRunLoglik(lines[1]);
file = close(file);
b = 1;

for i = 1:runs
    Filename =  string("snaq_h",h,"_id_",i,"_snaq.out");
    file = open(Filename);
    lines = readlines(file);
    logLike = eachRunLoglik(lines[1]);
    if (logLike < a)
        a = logLike;
        b = i;
    end
    file = close(file);
end

findTree = string("snaq_h",h,"_id_",b,"_snaq.out");
Tree = readTopology(findTree);
fileName = string("h",h+1,"BestStartingTree.out");

open(fileName, "w") do f
    write(fileName, Tree)
end

