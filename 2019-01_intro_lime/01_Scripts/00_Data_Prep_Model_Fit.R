library(dplyr)
library(here)
library(readr)


# Load data
customer <- read_csv(here("00_Data/raw", "WA_Fn-UseC_-Telco-Customer-Churn.csv"))

# 11 customers have TotalCharges missing, and all have tenure == 0, and also none of them have Churned,
# so deleting those records will not influence model. 
# drop cusotmerID, change SeniorCitizen to "Yes" / "No", Churn to factor
# rest of character columns to factors

customer_clean <- customer %>%
    filter(!is.na(TotalCharges)) %>%
    select(-c(customerID, TotalCharges, gender, PhoneService)) %>%
    mutate(SeniorCitizen = ifelse(SeniorCitizen == 1, "Yes", "No"),
           Churn = as.factor(Churn)) %>%
    mutate_if(is.character, as.factor)


write_csv(customer_clean, here("00_Data/clean/", "customer_clean.csv"))


library(caret)
library(gbm)
library(car)
library(nnet)
library(earth)
library(pROC)
library(vip)

set.seed(5432)
index <- createDataPartition(customer_clean$Churn, p=.75, list = FALSE)
trainData <- customer_clean[index,]
testData <- customer_clean[-index,]

fitControl <- trainControl(
    method = "repeatedcv",
    number = 5,
    repeats = 3,
    summaryFunction = twoClassSummary,
    verboseIter = TRUE,
    classProbs = TRUE
)

#########################################################
#
# glmnet model 
#
#########################################################
glmnet_grid <- expand.grid(alpha = 0:1, lambda = seq(0.0001, 1, length = 10))

set.seed(5432)
system.time(glmnet.fit <- train(Churn ~ .,data = trainData,
                                method = "glmnet",
                                metric = "ROC",
                                trControl = fitControl,
                                tuneGrid = glmnet_grid,
                                preProcess = c("center", "scale")))

#   user  system elapsed 
#   9.86    0.20   10.25 
#   user  system elapsed 
#  12.30    0.13   12.62 

glmnet.predict <- predict(glmnet.fit, newdata = testData)
saveRDS(glmnet.predict, file = "03_Models/glmnet.fit.rda")
#mean(glmnet.predict == testData$Churn)

#vip(glmnet.fit, fill = "#2b8cbe") + ggtitle("glmnet")
#varImp(glmnet.fit)
saveRDS(glmnet.fit, file = "03_Models/glmnet_model.rda")

#########################################################
#
# gbm model
#
#########################################################
gbm_grid <- expand.grid(interaction.depth = 1:3,
                        shrinkage = .1,
                        n.trees = c(50, 100, 150, 200),
                        n.minobsinnode = 10)

set.seed(5432)
system.time(gbm.fit <- train(Churn ~ .,data = trainData,
                             method = "gbm",
                             metric = "ROC",
                             trControl = fitControl,
                             tuneGrid = gbm_grid,
                             preProcess = c("center", "scale")))

#   user  system elapsed 
#   13.09    0.33   13.35 

#   user  system elapsed 
#  56.36    0.29   60.87 

gbm.predict <- predict(gbm.fit, newdata = testData)
saveRDS(gbm.predict, file = "03_Models/gbm.predict.rda")
#mean(gbm.predict == testData$Churn)

#varImp(gbm.fit)
#vip(gbm.fit, fill = "#2b8cbe") + ggtitle("GBM")
saveRDS(gbm.fit, file = "03_Models/gbm_model.rda")

#########################################################
#
# nnet model
#
#########################################################
nnet_grid <- expand.grid(.decay = c(0.25, 0.5, 0.1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7), 
                         .size = c(3, 5, 10, 20))

set.seed(5432)
system.time(nnet.fit <- train(Churn ~ .,data = trainData,
                              method = "nnet",
                              metric = "ROC",
                              trControl = fitControl,
                              tuneGrid = nnet_grid,
                              preProcess = c("center", "scale")))

#    user  system elapsed 
#  833.03    5.61  847.61 

nnet.predict <- predict(nnet.fit, newdata = testData)
saveRDS(nnet.predict, file = "03_Models/nnet.predict.rda")
#mean(nnet.predict == testData$Churn)

#varImp(nnet.fit)
#vip(nnet.fit, fill = "#2b8cbe") + ggtitle("nnet") 

saveRDS(nnet.fit, file = "03_Models/nnet_model.rda")


#########################################################
#
# Multivariate Adaptive Regression Spline
#
#########################################################
mars_grid <- expand.grid(degree = 1:3, 
                         nprune = seq(2, 100, length.out = 10) %>% 
                             floor())

set.seed(5432)
system.time(mars.fit <- train(Churn ~ .,data = trainData,
                              method = "earth",
                              trControl = fitControl,
                              tuneGrid = mars_grid,
                              preProcess = c("center", "scale"),
                              metric = "ROC"))

#   user  system elapsed 
#  625.75    9.99  639.66 


mars.predict <- predict(mars.fit, newdata = testData)
saveRDS(mars.predict, file = "03_Models/mars.predict.rda")
#mean(mars.predict == testData$Churn)

#varImp(mars.fit)
#summary(mars.fit)
#plot(mars.fit)
#vip(mars.fit, fill = "#2b8cbe") + ggtitle("MARS") 

saveRDS(mars.fit, file = "03_Models/mars_model.rda")

#########################################################
#
# xgboost
#
#########################################################
xgb_grid = expand.grid(eta = c(0.05,0.3, 0.075), # 3 
                       nrounds = c(50, 75, 100),  # 3
                       max_depth = 4:7,  # 4
                       min_child_weight = c(2.0, 2.25), #2 
                       colsample_bytree = c(0.3, 0.4, 0.5), # 3
                       gamma = 0, #1
                       subsample = 1) 

set.seed(5432)
system.time(xgb.fit <- train(Churn ~ .,data = trainData,
                             method = "xgbTree",
                             trControl = fitControl,
                             tuneGrid = xgb_grid,
                             preProcess = c("center", "scale"),
                             metric = "ROC"))

#   user  system elapsed 
# 877.45  328.03  500.64 
#   user  system elapsed 
# 1072.61  378.92  831.18 

xgb.predict <- predict(xgb.fit, newdata = testData)
saveRDS(xgb.predict, file = "03_Models/xgb.predict.rda")
#mean(xgb.predict == testData$Churn)
#varImp(xgb.fit)
#plot(varImp(xgb.fit), top=10, main="XGB")

#plot(xgb.fit)
#vip(xgb.fit, fill = "#2b8cbe") + ggtitle("xgBoost") 

saveRDS(xgb.fit, file="03_Models/xgb_model.rda")


