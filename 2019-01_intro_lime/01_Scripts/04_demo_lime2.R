library(lime)

# create explainer object for each model using lime::lime
explainer2_mars <- lime(train_x, mars.fit, n_bins = 6)
explainer2_gbm <- lime(train_x, gbm.fit, n_bins = 6)
explainer2_glmnet <- lime(train_x, glmnet.fit, n_bins = 6)
explainer2_nnet <- lime(train_x, nnet.fit, n_bins = 6)
explainer2_xgb <- lime(train_x, xgb.fit, n_bins = 6)


##########################################
#
#       SAMPLE Test Observation 1
#
#########################################

# create explanations using lime::explain (calls lime algorithm)
explanation3_mars <- explain(
  x = sample1,
  explainer = explainer2_mars,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation3_gbm <- explain(
  x = sample1,
  explainer = explainer2_gbm,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation3_glmnet <- explain(
  x = sample1,
  explainer = explainer2_glmnet,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation3_nnet <- explain(
  x = sample1,
  explainer = explainer2_nnet,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)

explanation3_xgb <- explain(
  x = sample1,
  explainer = explainer2_xgb,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  labels = "Yes"
)


pmars3 <- plot_features(explanation3_mars) + ggtitle(label = "mars explanation: sample 1, bins=6") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pglm3 <- plot_features(explanation3_glmnet) + ggtitle(label = "glmnet explanation: sample 1, bins=6") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pgbm3 <- plot_features(explanation3_gbm) + ggtitle(label = "gbm explanation: sample 1, bins=6") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pnnet3 <- plot_features(explanation3_nnet) + ggtitle(label = "nnet explanation: sample 1, bins=6") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pxgb3 <- plot_features(explanation3_xgb) + ggtitle(label = "xgb explanation: sample 1, bins=6") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))


gridExtra::grid.arrange(pmars3, pglm3, pgbm3, pnnet3, pxgb3, nrow=2)