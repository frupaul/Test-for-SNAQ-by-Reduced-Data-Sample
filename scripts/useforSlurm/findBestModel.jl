function eachRunLoglik(x)
    a = split(x);
    b  = parse(Float64, a[end]);
    return b
end

h = ARGS[1];

file = open(string("snaq_h",h,"_id_1_snaq.out"));
lines = readlines(file);
a = eachRunLoglik(lines[1]);
file = close(file);
b = 1;

for i = 1:100
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

fileId = string("Best Loglike ", a," Best Model ID ", b);

open(string("h",h,"bestModelID.txt"), "w") do f
    write("bestModelID.txt",fileId)
end

