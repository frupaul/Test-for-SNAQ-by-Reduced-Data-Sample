# Read the table with information of each run
info=read.csv("output.csv")

# Set up the initial arraies of different columns
structure=as.data.frame(table(info$comboName))
comboName = structure$Var1
numEachCombo = structure$Freq
Hmax = c() 
Nfail = c()  
FtolRel = c()
FtolAbs = c()
XtolAbs = c()
XtolRel = c()
LiktolAbs = c()
bestSeed = c()
meanLoglikValue = c()
varianceLoglikValue = c()
stdLoglikValue = c()
bestLoglik = c()

# The loop to read and calculate the values
for (i in 1:length(comboName)) {
  table = info[info$comboName == comboName[i],]
  Hmax[i] = table$Hmax[1]
  Nfail[i] = table$Nfail[1]  
  FtolRel[i] = table$FtolRel[1]
  FtolAbs[i] = table$FtolAbs[1]
  XtolAbs[i] = table$XtolAbs[1]
  XtolRel[i] = table$XtolRel[1]
  LiktolAbs[i] = table$LiktolAbs[1]
  meanLoglikValue[i] = mean(table$Loglik)
  varianceLoglikValue[i] = var(table$Loglik)
  stdLoglikValue[i] = sd(table$Loglik)
  bestLoglik[i] = min(table$Loglik)
  bestSeed[i] = table$Seed[table$Loglik==bestLoglik[i]]
}

# Gnerate the new table we want to show the summarized information
newTable = data.frame(comboName,Hmax,Nfail,FtolRel,FtolAbs,XtolAbs,
                      XtolRel,LiktolAbs,bestSeed,bestLoglik,meanLoglikValue,varianceLoglikValue,
                      stdLoglikValue)
