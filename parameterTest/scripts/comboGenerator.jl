function comb(input)
    a = mod(input,5);
    b = mod(input-a,4);
    c = mod(input-a-b,3);
    d = mod(input-a-b-c,2);
    e = mod(input-a-b-c-d,2);
    comb = [e+1,d+1,a+1,c+1,b+1];
    return comb
end
