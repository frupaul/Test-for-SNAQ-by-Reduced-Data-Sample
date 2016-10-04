Pkg.add("PhyloNetworks");
Pkg.build("PhyloNetworks");
Pkg.add("Datetime");
Pkg.build("Datetime");
Pkg.update();
using Datetime;
using PhyloNetworks;
cd("$(homedir())/Desktop/Research/2016fall/parameterTest/testOutfile/N6");

XTA = [0.000001, 0.001];
XTR = [0.001, 0.01];
FTA = [0.000001, 0.00001, 0.0001, 0.001, 0.01];
FTR = 0.00001;
Ratio = [1, 100, 10000];
NF = [100,75,50,25];
Runs = 2;
runTime = Array{Float64}(240,2);
runBestLoglik = Array{Float64}(240);
runLoglik = Array{Float64}(240,2);
runElapsedTime = Array{Float64}(240);

function eachRunTimeSummary(x,y)
    dat1 = Dates.DateTime(x, "e u dd HH:MM:SS yyyy");
    dat2 = Dates.DateTime(y, "e u dd HH:MM:SS yyyy");
    Diff = Int(dat2 - dat1)/(60*1000);
    return Diff
end

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

function findTimeRow(x,y)
    a = Array{Int}(Runs);
    b = 1;
    for i = 1:length(x)
        c = split(x[i]);
        if length(c) != 0
            if c[1] == y
                a[b] = i+1;
                b = b+1;
            end
        end
    end
    return a
end


run = 1;
for a = XTA[1:end]
    for b = XTR[1:end]
        for c = NF[1:end]
            for d = Ratio[1:end]
                for e = FTA[1:end]
                    LTA = d*e;
                    Filename =  string("N6nf",c,"xta",a,"xtr",b,"fta",e,"ftr",FTR,"lta",LTA,"_snaq.out");
                    file = open(Filename);
                    lines = readlines(file);
                    runElapsedTime[run] = elapsedTime(lines[3]);
                    runBestLoglik[run] = eachRunLoglik(lines[1]);
                    for f = 1:2
                        runLoglik[run,f] = eachRunLoglik(lines[f+5]);
                    end
                    run = run + 1;
                    file = close(file);
                end
            end
        end
    end
end

run = 1;
for a = XTA[1:end]
    for b = XTR[1:end]
        for c = NF[1:end]
            for d = Ratio[1:end]
                for e = FTA[1:end]
                    sum = 0;
                    LTA = d*e;
                    Filename =  string("N6nf",c,"xta",a,"xtr",b,"fta",e,"ftr",FTR,"lta",LTA,"_snaq.log");
                    file = open(Filename);
                    lines = readlines(file);
                    timeLines = findTimeRow(lines, "seed:");
                    for f = 1:length(timeLines)-1
                        g = f+1
                        h = timeLines[f];
                        i = timeLines[g];
                        runTime[run,f] = eachRunTimeSummary(lines[h],lines[i]);
                        sum = sum + runTime[run,f];
                    end
                    runTime[run,end] = (runElapsedTime[run] - sum)/60;
                    run = run + 1;
                    file = close(file);
                end
            end
        end
    end
end

#Use grep in Julia and save the specific line into a string and use string[end] to find the loglik number and convert it to numbers.

#use Date Pkg to do compute the time for each run
#DateTime Pkg
#dat1 = Dates.DataTime("Thu Jun 16 21:41:50 2016", "e u dd HH:MM:SS yyyy")
#dat2 - dat1
#Transfer them to minutes Int(dat2 - dat1)/(60*1000)
#readTree = readTree2CF("treeList.tre");
