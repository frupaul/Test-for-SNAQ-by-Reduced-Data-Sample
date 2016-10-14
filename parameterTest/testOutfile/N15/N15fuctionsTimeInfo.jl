
using DataFrames;
using PhyloNetworks;
cd("$(homedir())/Desktop/Research/2016fall/parameterTest/testOutfile/N15");

XTA = [0.000001];
XTR = [0.001];
FTA = [0.000001, 0.00001];
FTR = 0.00001;
Ratio = [1, 100];
NF = [100,75,50,25];
Runs = 1;
totalRuns = 20;

runLoglik = Array{Float64}(totalRuns,Runs);
runElapsedTime = Array{Float64}(totalRuns);

function eachRunLoglik(x)
    a = split(x);
    b  = parse(Float64, a[end]);
    return b
end

function elapsedTime(x)
    a = split(x);
    b = parse(Float64, a[3]);
    return b
end

run = 1;
for a = XTA[1:end]
    for b = XTR[1:end]
        for c = NF[1:end]
            for d = Ratio[1:end]
                for e = FTA[1:end]
                    LTA = d*e;
                    Filename =  string("nf",c,"xta",a,"xtr",b,"fta",e,"ftr",FTR,"lta",LTA,"_snaq.out");
                    file = open(Filename);
                    lines = readlines(file);
                    runElapsedTime[run] = elapsedTime(lines[3]);
                    runLoglik[run] = eachRunLoglik(lines[1]);
                    run = run + 1;
                    file = close(file);
                end
            end
        end
    end
end

df = DataFrame(runLoglik, runElapsedTime);
write(df, "df.txt");


#Use grep in Julia and save the specific line into a string and use string[end] to find the loglik number and convert it to numbers.

#use Date Pkg to do compute the time for each run
#DateTime Pkg
#dat1 = Dates.DataTime("Thu Jun 16 21:41:50 2016", "e u dd HH:MM:SS yyyy")
#dat2 - dat1
#Transfer them to minutes Int(dat2 - dat1)/(60*1000)
#readTree = readTree2CF("treeList.tre");

#include("function.jl")
