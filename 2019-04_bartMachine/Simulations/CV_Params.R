trctrl <- trainControl(method = "cv", number = 5,allowParallel = TRUE)

tune.grid.XGboost <- expand.grid(nrounds=c(100,500),
                                 max_depth = c(3:7),
                                 eta = c(.1, .3, .7),
                                 gamma = c(0),
                                 colsample_bytree = c(1),
                                 subsample = c(1),
                                 min_child_weight = c(1))

tune.grid.RandomForest <- expand.grid(mtry = c(1,2))
