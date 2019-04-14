library(MASS)
library(tidyverse)

# Give bartMachine 10GB of memory to use
options(java.parameters = "-Xmx10g")
library(bartMachine)

# Allow barTMachine to use all but one core
numcores <- parallel::detectCores()
set_bart_machine_num_cores(numcores - 1)

data(Boston)
Boston %>% head %>% View

RegressMod <- lm(formula = medv ~ ., data = Boston)
summary(RegressMod)

set.seed(1)
train <- sample(1:nrow(Boston), .8*nrow(Boston))

y <- Boston$medv
X <- Boston %>% dplyr::select(-c("medv"))

bart.model <- bartMachine(X,y,
                          num_trees = 200,
                          num_burn_in = 1000,
                          num_iterations_after_burn_in = 5000)
bart.model
  
k_fold_cv(X, y, k_folds = 5,
          num_trees = 200,
          num_burn_in = 1000,
          num_iterations_after_burn_in = 5000)

rmse_by_num_trees(bart.model, num_replicates = 20)  

bart.model.cv <- bartMachineCV(X, y,
                               num_burn_in = 1000,
                               num_iterations_after_burn_in = 5000)

k_fold_cv(X, y, k_folds = 5,k=2,nu=3, q=.90,
          num_trees = 50,
          num_burn_in = 1000,
          num_iterations_after_burn_in = 5000)

investigate_var_importance(bart.model.cv, num_replicates_for_avg = 20)
interaction_investigator(bart.model.cv, num_replicates_for_avg = 20)

VarSel <- var_selection_by_permute(bart.model.cv,bottom_margin = 5)
VarSel$important_vars_local_names

RegressMod <- lm(formula = medv ~ ., data = Boston)
summary(RegressMod)

pd_plot(bart.model.cv, j = "lstat")
# The below takes a long time!
#cov_importance_test(bart.model.cv, covariates = "lstat") 

pd_plot(bart.model.cv, j = "rm")
# The below takes a long time!
#cov_importance_test(bart.model.cv, covariates = "rm")

## check your asusmptions
check_bart_error_assumptions(bart.model.cv)  
plot_convergence_diagnostics(bart.model.cv)  

plot_y_vs_yhat(bart.model.cv, credible_intervals = TRUE)

# predictions
MeanDF <- colMeans(X) %>% t %>% data.frame
MeanDF %>% head
predict(bart.model.cv, new_data = MeanDF)
calc_credible_intervals(bart.model.cv, MeanDF, ci_conf = 0.95) %>% round(digits=2)


  
  
  
  
  
  
    