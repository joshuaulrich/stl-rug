#-----------------------------------------------------------------------------#
# This code is a quick simulation study to demonstrate the ability of the BART
# model to capture the patterns in complex systems.  xgboost and randomforest 
# are cross validated but still do not outperform BART with default parameters.
#-----------------------------------------------------------------------------#

#Set the memory you will give BART here
options(java.parameters = "-Xmx50g")
library(bartMachine)
numcores <- parallel::detectCores()
set_bart_machine_num_cores(numcores - 1)

library(xgboost)
library(randomForestSRC)
library(caret)
library(tidyverse)
library(rpart)
source("CV_Params.R")
source("Data_Generation.R")

nsim <- 100  # number of data replications
ntrain <- 2000
ntest <- 500
# number of "extra" X variables not related to the response.
# see Data_generation.R
p.null <- 0 
sigma <- 1
AllDataTypes <- c("Friedman","Mirsha","Exp","Linear")

#--------------------------------------------------------------------------#
# Create lists to store simulation resuts
Sim.Result.Empty <- data.frame(RMSE = rep(NA,nsim),
                         TIME = rep(NA,nsim))
All.Res.Empty <- list(BART = Sim.Result.Empty,
                      XGBoost = Sim.Result.Empty,
                      RandomF = Sim.Result.Empty,
                      LinReg = Sim.Result.Empty)

All.Results <- list(All.Res.Empty,All.Res.Empty,All.Res.Empty,All.Res.Empty)
names(All.Results) <- AllDataTypes
#--------------------------------------------------------------------------#

n <- ntrain + ntest
Start <- proc.time()["elapsed"]
for(Cur.Fun in AllDataTypes)
{
  for(i in 1:nsim)
  {
    #Generate Data
    AllData <- Generate_Data(nonlin_f = Cur.Fun, n, p.null, sigma)
      
    y.train <- AllData$y[1:ntrain]
    y.test <- AllData$y[(ntrain+1):n]
    
    X.train <- AllData[1:ntrain,-1] 
    X.test <- AllData[(ntrain+1):n,-1] 
      
    #Fit BART model and store time
    All.Results[[Cur.Fun]]$BART$TIME[i] <- system.time(
    bart.model <- bartMachine(X.train,y.train,
                              num_trees = 200,
                              num_burn_in = 800,
                              num_iterations_after_burn_in = 5000,
                              verbose = FALSE)
    )["elapsed"]
      
    #Fit Random Forest model and store time
    All.Results[[Cur.Fun]]$RandomF$TIME[i] <- system.time(
    RF.model <- train(y~., data = AllData[1:ntrain,], method = "rf",
                        trControl=trctrl,
                        tuneGrid = tune.grid.RandomForest)$finalModel
    )["elapsed"]

    #Fit EXTREME gradient boosting model and store time
    dtrain <- xgb.DMatrix(data = as.matrix(X.train), label= y.train)
    dtest <- xgb.DMatrix(data = as.matrix(X.test), label= y.test)
    
    All.Results[[Cur.Fun]]$XGBoost$TIME[i] <- system.time(
    XG.model <- train(y~., data = AllData[1:ntrain,], method = "xgbTree",
                    trControl=trctrl,
                    tuneGrid = tune.grid.XGboost,
                    tuneLength = 10)$finalModel
    )["elapsed"] 
    
      
    #Fit linear regression model for funsies lol
    All.Results[[Cur.Fun]]$LinReg$TIME[i] <- system.time(
    LR.model <- lm(y~., data = AllData[1:ntrain,])
    )["elapsed"]
    
    #Get the predictions and find the holdout RMSE values, storing into the results DF
    BART.preds <- predict(bart.model, X.test)
    XG.preds   <- predict(XG.model, dtest)
    RF.preds   <- predict(RF.model, X.test)
    LR.preds   <- predict(LR.model, X.test)
      
    All.Results[[Cur.Fun]]$BART$RMSE[i]    <- sqrt(mean((BART.preds - y.test)^2))
    All.Results[[Cur.Fun]]$XGBoost$RMSE[i] <- sqrt(mean((XG.preds - y.test)^2))
    All.Results[[Cur.Fun]]$RandomF$RMSE[i] <- sqrt(mean((RF.preds - y.test)^2))
    All.Results[[Cur.Fun]]$LinReg$RMSE[i]  <- sqrt(mean((LR.preds - y.test)^2))
    
    sprintf("Finished iteration %s out of %s for %s",i,nsim,Cur.Fun) %>% print
  }
}

print(sprintf("%s simulations finished in %s seconds.  Averaged %s seconds per sim",
        nsim,
        proc.time()["elapsed"] - Start,
        (proc.time()["elapsed"] - Start)/nsim))

# hastilly written functions to aggregate results by function and method
TabNames <- lapply(All.Results,function(l) names(l))[[1]]
Results <- lapply(All.Results,function(l) lapply(l, function(tab) colMeans(tab))) %>%
  lapply(function(x) x %>% unlist %>% matrix(.,ncol=2,byrow=TRUE))
for(i in 1:length(Results))
{
  rownames(Results[[i]]) <- TabNames
  colnames(Results[[i]]) <- c("mean.RMSE","mean.TIME")
}

# Same as above but with standard deviations of the simulation results
SDResults <- lapply(All.Results,function(l) lapply(l, function(tab) apply(tab,2,function(x) sd(x)/sqrt(length(x))))) %>%
  lapply(function(x) x %>% unlist %>% matrix(.,ncol=2,byrow=TRUE))
for(i in 1:length(Results))
{
  rownames(SDResults[[i]]) <- TabNames
  colnames(SDResults[[i]]) <- c("mean.RMSE","mean.TIME")
}
