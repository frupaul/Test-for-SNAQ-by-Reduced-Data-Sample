# The function was imported into oneSnaqH.jl
# to generate 240 combinations of parameters in total.
# It will return an array containing nubmers respect
# to the specific parameters initialized in the
# arraies in oneSnaqH.jl

function comb(input)
    a = mod(input,5);
    ia = (input-a)/5;
    b = mod(ia,4);
    ib = (ia-b)/4;
    c = mod(ib,3);
    ic = (ib-c)/3;
    d = mod(ic,2);
    id = (ic-d)/2;
    e = mod(id,2);
    comb = [e+1,d+1,a+1,c+1,b+1];
    return comb
end

# for i in 0:239
#     for j in 0:239
#         if i != j
#             if comb(i) == comb(j)
#                 println(comb(i) == comb(j))
#             end
#         end
#     end
# end

