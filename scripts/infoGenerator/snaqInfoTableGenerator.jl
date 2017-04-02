#Pkg.add("PhyloNetworks");
#Pkg.add("Lazy")
#Pkg.add("DataFrames");
#Pkg.update();
using PhyloNetworks;

if length(ARGS) < 3 && length(ARGS) > 0

    directory = ARGS[1]; # read the directory

    if length(ARGS) > 1

        realTopo = ARGS[2]; # read the root at the node

    end

else

    error("need at least 1 parameter and at most 2 parameters: the address of
          the directory and the file name of the true topology")

end



# Set the current working directory to be user's input address

dir = string("$(homedir())",directory);
cd(dir);

fileNames = filter(x->contains(x,".log"),readdir(pwd())); # Read only the names of *.log files

# The function is used to read the starting time of two runs and return the
# difference which is the consuming time for one run.

function eachRunTimeSummary(x,y)

    if contains(x,"AM") || contains(x,"PM")
        # for the version that print time with AM and PM
        a = 1
        if contains(x, "AM")
            x = split(x);
            loc = find(x -> x=="AM",x);
            Time = split(x[loc-1][1],":");
            if Time[1] == "12"
                Time[1] = "$(parse(Int, Time[1])-12)";
            end
            x[loc-1] = string(Time[1],":",Time[2],":",Time[3]);
            x = join(x, " ");
        end
        if contains(y, "AM")
            y = split(y);
            loc = find(x -> x=="AM",y);
            Time = split(y[loc-1][1],":");
            if Time[1] == "12"
                Time[1] = "$(parse(Int, Time[1])-12)";
            end
            y[loc-1] = string(Time[1],":",Time[2],":",Time[3]);
            y = join(y, " ");
        end
        if contains(x, "PM")
            x = split(x);
            loc = find(x -> x=="PM",x);
            Time = split(x[loc-1][1],":");
            if Time[1] != "12"
                Time[1] = "$(parse(Int, Time[1])+12)";
            end
            x[loc-1] = string(Time[1],":",Time[2],":",Time[3]);
            x = join(x, " ");
        end
        if contains(y, "PM")
            y = split(y);
            loc = find(x -> x=="PM",y);
            Time = split(y[loc-1][1],":");
            if Time[1] != "12"
                Time[1] = "$(parse(Int, Time[1])+12)";
            end
            y[loc-1] = string(Time[1],":",Time[2],":",Time[3]);
            y = join(y, " ");
        end
    else
        a = 2
    end

    if a == 1
        dat1 = DateTime(x, "e d u y H:M:S");
        dat2 = DateTime(y, "e d u y H:M:S");
        Diff = Float64(dat2 - dat1)/1000;
    elseif a == 2
        # for the latest PhyloNetworks, the time is in y-u-d H:M:S form.
        dat1 = DateTime(x, "y-u-d H:M:S");
        dat2 = DateTime(y, "y-u-d H:M:S");
        Diff = Float64(dat2 - dat1)/1000;
    end
    return Diff
end

# Initialize the arrayList to save all the information we want for each run.

parameterInfoList = Array{String}[]; # The arrayList to save the parameter array for each file
runSeed = Array{String}[]; # The arrayList used to store seed for each run
runLoglik = Array{String}[]; # The arrayList used to store loglikValue for each run
runTimeList = Array{Float64}[]; # The arrayList used to store the time for each run
runTopology = Array{String}[]; # The arrayList used to store the topology for each run
run = 0; # Count the total run number of all files

# Use a for loop to find information from each log file.

for i in fileNames[1:end]

    # Import bash command grep and sed to help search and grab the information we want.

    parameterInfo = Array{String}(8); # The array to save eight parameters: hmax, ftolRel, ftolAbs, xtoLAbs, xtolRel, Nfails, likotolAbs and runs

    parameterInfo[1] = readstring(pipeline(`grep "hmax =" $i`, `grep -Eo "\d+"`)); # Find hmax
    parameterInfo[2] = readstring(pipeline(`grep -Eo "ftolRel=.*" $i`, `sed -E 's/ftolRel=(.*), fto.*/\1/'`)); # Find ftolRel
    parameterInfo[3] = readstring(pipeline(`grep -Eo "ftolAbs=.*" $i`, `sed -E 's/ftolAbs=(.*),/\1/'`)); # Find ftolAbs
    parameterInfo[4] = readstring(pipeline(`grep -Eo "xtolAbs=.*" $i`, `sed -E 's/xtolAbs=(.*), xto.*/\1/'`)); # Find xtolAbs
    parameterInfo[5] = readstring(pipeline(`grep -Eo "xtolRel=.*" $i`, `sed -E 's/xtolRel=(.*)\./\1/'`)); # Find xtolRel
    parameterInfo[6] = readstring(pipeline(`grep -Eo "failed proposals =.*" $i`, `sed -E 's/failed proposals = (.*), likt.*/\1/'`)); # Find Nfails
    parameterInfo[7] = readstring(pipeline(`grep -Eo "liktolAbs =.*" $i`, `sed -E 's/liktolAbs = (.*)\./\1/'`)); # Find liktolAbs
    parameterInfo[8] = readstring(pipeline(`grep -Eo "BEGIN: .*" $i`, `sed -E 's/BEGIN: (.*) run.*/\1/'`)); # Find number of runs

    err = 0;
    errNum = 0;
    try
        err = readstring(`grep -e "Error" $i`);
    catch
    end

    if err != 0
        err = parse(Int,split(err)[7]);
        errNum = 1;
    end

    parameterInfo[8] = string(parse(Int,parameterInfo[8])-errNum);

    push!(parameterInfoList,parameterInfo); # Save the parameter array of one file into the arrayList

    run = run + parse(Int,parameterInfo[8]);
    # println(run);
    # Look for all the information we need for each run in one log file.

    seed = Array{String}(parse(Int,parameterInfo[8]));
    mainseed = readstring(pipeline(`grep -Eo "main seed.*" $i`, `sed -E 's/main seed (.*)/\1/'`)); # Grab the main seed for repeating same running
    seedAll = split(readstring(pipeline(`grep -Eo "seed:.*" $i`,`sed -E 's/seed: (.*) for.*/\1/'`)));
    # Store the seed of each run
    if err != 0
        if err == 1
            seed = seedAll[(err+1):length(seedAll)];
        elseif err == length(seed)+1
            seed = seedAll[1:length(seed)];
        else
            seed[1:(err-1)] = seedAll[1:(err-1)];
            seed[err:length(seed)] = seedAll[(err+1):length(seedAll)];
        end
    else
        seed = seedAll;
    end

    push!(runSeed,seed); # Save the seed into the arrayList

    loglik = Array{String}(parse(Int,parameterInfo[8]));
    loglik = split(readstring(pipeline(`grep -Eo "loglik of best.*" $i`, `sed -E 's/loglik of best (.*)/\1/'`))); # Find the loglik value
    ##loglik = map(x->parse(Float64,x),a);
    push!(runLoglik,loglik);

    # Find the topology of each run.

    topology = Array{String}(parse(Int, parameterInfo[8]));
    topologyLine = split(readstring(`grep -A 1 "FINISHED SNaQ for.*" $i`),"\n");
    for j in 1:length(topology)
        topology[j] = topologyLine[3*j-1];
    end
    push!(runTopology,topology); # Save the topology for future comparison

    # Save the info of time in each run.

    runTime = Array{String}(parse(Int, parameterInfo[8])+errNum+1);
    runTimeLine = split(readstring(`grep -A 1 "seed:.*" $i`),"\n");
    for k in 1:(parse(Int, parameterInfo[8])+errNum)
        runTime[k] = runTimeLine[3*k-1];
    end
    endTimeLine = split(readstring(`grep -B 1 "MaxNet is.*" $i`),"\n");
    runTime[end] = endTimeLine[1];

    # Count the time used for each run.

    runTimeNum = Array{Float64}(parse(Int, parameterInfo[8]));
    numJ = 1;
    for j in 1:length(runTimeNum)
        if j == err
            numJ = j+1;
        end
        runTimeNum[j] = eachRunTimeSummary(runTime[numJ],runTime[numJ+1]);
        numJ = numJ + 1;
    end

    push!(runTimeList,runTimeNum); # Save the time info of runs in each file

end

# Use dataframe to help generate the table including the information of each run.

using DataFrames; # Contain the function DataFrame

# Initialize the arraies saving the information used as columns in DataFrame.

Hmax = Array{Int}(run);
Nfail = Array{Int}(run);
ftolRel = Array{Float64}(run);
ftolAbs = Array{Float64}(run);
xtolAbs = Array{Float64}(run);
xtolRel = Array{Float64}(run);
liktolAbs = Array{Float64}(run);
combineName = Array{String}(run);

# Initialize the array so that it could be easy to combine in for loop.

seed = runSeed[1];
sameToBestTopology = Array{Int}(run);
distCol = Array{Int}(run);
topo = runTopology[1];
loglik = runLoglik[1];
runTime = runTimeList[1];

# Repetitively set the parameters for each run.

r = 0;
for i in 1:length(parameterInfoList)
    for j in 1:parse(Int,parameterInfoList[i][8])

        r = r + 1;
        Hmax[r] = parse(Int, parameterInfoList[i][1]);
        Nfail[r] = parse(Int, parameterInfoList[i][6]);
        ftolRel[r] = parse(Float64, parameterInfoList[i][2]);
        ftolAbs[r] = parse(Float64, parameterInfoList[i][3]);
        xtolAbs[r] = parse(Float64, parameterInfoList[i][4]);
        xtolRel[r] = parse(Float64, parameterInfoList[i][5]);
        liktolAbs[r] = parse(Float64, parameterInfoList[i][7]);
        combineName[r] = string(Hmax[r],Nfail[r],ftolRel[r],
                                ftolAbs[r],xtolAbs[r],xtolRel[r],liktolAbs[r]);

    end
end

# Combine all the values in the order of the runs.

for i in 2:length(fileNames)

    seed = [seed;runSeed[i]];
    loglik = [loglik;runLoglik[i]];
    runTime = [runTime;runTimeList[i]];
    topo = [topo;runTopology[i]];

end

if length(ARGS) > 1

    trueNet = readTopology(realTopo); # read the true topology
    rootAtNode = "15";

    # The loop will save 1 when the result topology is the same to the true topology,
    # otherwise it will save 0.

    for i in 1:length(sameToBestTopology)

        try
            topologyCompare = readTopology(topo[i]);
            rootatnode!(topologyCompare,rootAtNode);
            dist = hardwiredClusterDistance(trueNet, topologyCompare, true);
            distCol[i] = dist;
            sameToBestTopology[i] = (dist == 0) ? 1:0;
        catch

        end

    end

end

# Generate the DataFrame and write it into a csv file.

df = DataFrame(comboName=combineName,Hmax=Hmax,Nfail=Nfail,FtolRel=ftolRel,FtolAbs=ftolAbs,XtolAbs=xtolAbs,
               XtolRel=xtolRel,LiktolAbs=liktolAbs,Seed=seed,Loglik=loglik,RunTime=runTime,TrueTopo=sameToBestTopology, Dist = distCol);
writetable("output.csv",df)

# SameToBestTopology=sameToBestTopology

