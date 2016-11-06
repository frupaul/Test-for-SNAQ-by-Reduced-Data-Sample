function eachRunLoglik(x)
    a = split(x);
    b  = parse(Float64, a[end]);
    return b
end

file = open("snaq_h0_id_1_snaq.out");
lines = readlines(file);
a = eachRunLoglik(lines[1]);
file = close(file);
b = 1;

for i = 1:100
    Filename =  string("snaq_h0_id_",i,"_snaq.out");
    file = open(Filename);
    lines = readlines(file);
    logLike = eachRunLoglik(lines[1]);
    if (logLike < a)
        a = logLike;
        b = i;
    end
    file = close(file);
end

println(a);
println(b);
