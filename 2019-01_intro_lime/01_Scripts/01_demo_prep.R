# prep script for Live Demo - binary classification

# load libraries
library(dplyr)
library(here)
library(readr)
library(lime)
library(vip)
library(caret)
library(patchwork)
library(gbm)
library(gridExtra)
library(tibble)

# load saved data set
#customer_clean <- read_csv(here("00_Data/clean", "customer_clean.csv"))

# split data
# set.seed(5432)
# index <- createDataPartition(customer_clean$Churn, p=.75, list = FALSE)
# trainData <- customer_clean[index,]
# testData <- customer_clean[-index,]

trainData <- readRDS(here("00_Data/trainData.rda"))
testData <- readRDS(here("00_Data/testData.rda"))

# separate features and response for lime
train_x <- trainData %>% select(-Churn)
train_y <- trainData %>% select(Churn)
test_x <- testData %>% select(-Churn)
test_y <- testData %>% select(Churn)

# load saved models
gbm.fit <- readRDS(here("03_Models/","gbm_model.rda"))
glmnet.fit <- readRDS(here("03_Models/", "glmnet_model.rda"))
mars.fit <- readRDS(here("03_Models/", "mars_model.rda"))
nnet.fit <- readRDS(here("03_Models/", "nnet_model.rda"))
xgb.fit <- readRDS(here("03_Models/", "xgb_model.rda"))

# gbm.predict <- readRDS(here("03_Models/", "gbm.predict.rda"))
# glmnet.predict <- readRDS(here("03_Models/", "glmnet.predict.rda"))
# mars.predict <- readRDS(here("03_Models/", "mars.predict.rda"))
# nnet.predict <- readRDS(here("03_Models/", "nnet.predict.rda"))
# xgb.predict <- readRDS(here("03_Models/", "xgb.predict.rda"))


# predict using all five models on test data
set.seed(5432)
glmnet.predict <- predict(glmnet.fit, newdata = testData)
gbm.predict <- predict(gbm.fit, newdata = testData)
nnet.predict <- predict(nnet.fit, newdata = testData)
mars.predict <- predict(mars.fit, newdata = testData)
xgb.predict <- predict(xgb.fit, newdata = testData)

# Getting some random values to use here
set.seed(seed = 14412)

sample_values <- test_x[sample(1:nrow(test_x),200, replace = FALSE),]

# Create a sample without replacement (i.e. take the ball out and don't put it back in)
sample1 <- sample_values[sample(1:nrow(sample_values), 1, replace = FALSE),]

# Remove the sampled items from the vector of values
sample_values <- sample_values[!(sample_values %in% sample1)]

# Another sample, and another removal
sample2 <- sample_values[sample(1:nrow(sample_values), 1, replace = FALSE),]
sample_values <- sample_values[!(sample_values %in% sample2)]

# Another sample, and another removal
sample3 <- sample_values[sample(1:nrow(sample_values), 1, replace = FALSE),]
sample_values <- sample_values[!(sample_values %in% sample3)]

# Another sample, and another removal
sample4 <- sample_values[sample(1:nrow(sample_values), 1, replace = FALSE),]
sample_values <- sample_values[!(sample_values %in% sample4)]
