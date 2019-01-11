library(lime)

# create explainer object for each model using lime::lime
explainer_mars <- lime(train_x, mars.fit, n_bins = 4)
explainer_gbm <- lime(train_x, gbm.fit, n_bins = 4)
explainer_glmnet <- lime(train_x, glmnet.fit, n_bins = 4)
explainer_nnet <- lime(train_x, nnet.fit, n_bins = 4)
explainer_xgb <- lime(train_x, xgb.fit, n_bins = 4)

# look at class of explainer object
class(explainer_xgb)

##########################################
#
#       SAMPLE Test Observation 1
#
#########################################

# create explanations using lime::explain (calls lime algorithm)
explanation_mars <- explain(
  x = sample1,
  explainer = explainer_mars,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation_gbm <- explain(
  x = sample1,
  explainer = explainer_gbm,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation_glmnet <- explain(
  x = sample1,
  explainer = explainer_glmnet,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation_nnet <- explain(
  x = sample1,
  explainer = explainer_nnet,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation_xgb <- explain(
  x = sample1,
  explainer = explainer_xgb,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)


pmars1 <- plot_features(explanation_mars) + ggtitle(label = "mars explanation: sample 1, bins=4") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pglm1 <- plot_features(explanation_glmnet) + ggtitle(label = "glmnet explanation: sample 1, bins=4") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pgbm1 <- plot_features(explanation_gbm) + ggtitle(label = "gbm explanation: sample 1, bins=4") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pnnet1 <- plot_features(explanation_nnet) + ggtitle(label = "nnet explanation: sample 1, bins=4") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pxgb1 <- plot_features(explanation_xgb) + ggtitle(label = "xgb explanation: sample 1, bins=4") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))


gridExtra::grid.arrange(pmars1, pglm1, pgbm1, pnnet1, pxgb1, nrow=2)

##########################################
#
#       SAMPLE Test Observation 2
#
#########################################

# create explanations using lime::explain (calls lime algorithm)
explanation2_mars <- explain(
  x = sample2,
  explainer = explainer_mars,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation2_gbm <- explain(
  x = sample2,
  explainer = explainer_gbm,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation2_glmnet <- explain(
  x = sample2,
  explainer = explainer_glmnet,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation2_nnet <- explain(
  x = sample2,
  explainer = explainer_nnet,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation2_xgb <- explain(
  x = sample2,
  explainer = explainer_xgb,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)


pmars2 <- plot_features(explanation2_mars) + ggtitle(label = "mars explanation: sample 2") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pglm2 <- plot_features(explanation2_glmnet) + ggtitle(label = "glmnet explanation: sample 2") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pgbm2 <- plot_features(explanation2_gbm) + ggtitle(label = "gbm explanation: sample 2") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pnnet2 <- plot_features(explanation2_nnet) + ggtitle(label = "nnet explanation: sample 2") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pxgb2 <- plot_features(explanation2_xgb) + ggtitle(label = "xgb explanation: sample 2") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

gridExtra::grid.arrange(pmars2, pglm2, pgbm2, pnnet2, pxgb2, nrow=2)

