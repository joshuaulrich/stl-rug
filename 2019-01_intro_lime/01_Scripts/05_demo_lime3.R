# gbm vs xgb
# Model   Accuracy AccuracyLower AccuracyUpper    F1
# <chr>      <dbl>         <dbl>         <dbl> <dbl>
#   1 GBM        0.809         0.790         0.827 0.588
# 2 glmenet    0.804         0.784         0.822 0.598
# 3 nnet       0.803         0.784         0.821 0.591
# 4 MARS       0.814         0.795         0.832 0.616
# 5 xgb        0.809         0.790         0.827 0.595

gridExtra::grid.arrange(pgbm1, pxgb1, pgbm2, pxgb2, nrow=2)

# compare bins = 4 to bins = 6 for same samples
gridExtra::grid.arrange(pmars1, pmars3, pnnet1, pnnet3, nrow=2)

##########################################
#
#       SAMPLE Test Observation 1
#       new explain parameters
#
#########################################

# create explanations using lime::explain (calls lime algorithm)
explanation4_mars <- explain(
  x = sample1,
  explainer = explainer2_mars,
  n_permutations = 5000,
  dist_fun = "euclidian",
  kernel_width = .75,
  n_features = 8,
  feature_select = "forward_selection",
  labels = "Yes"
)

explanation4_gbm <- explain(
  x = sample1,
  explainer = explainer2_gbm,
  n_permutations = 5000,
  dist_fun = "euclidian",
  kernel_width = .75,
  n_features = 8,
  feature_select = "forward_selection",
  labels = "Yes"
)

explanation4_glmnet <- explain(
  x = sample1,
  explainer = explainer2_glmnet,
  n_permutations = 5000,
  dist_fun = "euclidian",
  kernel_width = .75,
  n_features = 8,
  feature_select = "forward_selection",
  labels = "Yes"
)

explanation4_nnet <- explain(
  x = sample1,
  explainer = explainer2_nnet,
  n_permutations = 5000,
  dist_fun = "euclidian",
  kernel_width = .75,
  n_features = 8,
  feature_select = "forward_selection",
  labels = "Yes"
)

explanation4_xgb <- explain(
  x = sample1,
  explainer = explainer2_xgb,
  n_permutations = 5000,
  dist_fun = "euclidian",
  kernel_width = .75,
  n_features = 8,
  feature_select = "forward_selection",
  labels = "Yes"
)


pmars4 <- plot_features(explanation4_mars) + ggtitle(label = "mars expl.n: sample 1, bins=6, tuned") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pglm4 <- plot_features(explanation4_glmnet) + ggtitle(label = "glmnet expl.: sample 1, bins=6, tuned") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pgbm4 <- plot_features(explanation4_gbm) + ggtitle(label = "gbm expl.: sample 1, bins=6, tuned") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pnnet4 <- plot_features(explanation4_nnet) + ggtitle(label = "nnet expl.: sample 1, bins=6, tuned") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pxgb4 <- plot_features(explanation4_xgb) + ggtitle(label = "xgb expl.: sample 1, bins=6, tuned") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))



gridExtra::grid.arrange(pmars3, pmars4, pglm3, pglm4, nrow=2)
gridExtra::grid.arrange(pgbm3, pgbm4, pnnet3, pnnet4, nrow=2)
gridExtra::grid.arrange(pxgb3, pxgb4, nrow=2)

# remove 'labels', use n_labels = 1 & 2
explanation5_xgb <- explain(
  x = sample2,
  explainer = explainer_xgb,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  #labels = "Yes"
  n_labels = 1
)

explanation6_xgb <- explain(
  x = sample2,
  explainer = explainer_xgb,
  n_permutations = 5000,
  dist_fun = "manhattan",
  kernel_width = .75,
  n_features = 10,
  feature_select = "lasso_path",
  #labels = "Yes"
  n_labels = 2
)

pxgb5 <- plot_features(explanation5_xgb) + ggtitle(label = "xgb explanation: sample 2, n_labels=1") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pxgb6 <- plot_features(explanation6_xgb) + ggtitle(label = "xgb explanation: sample 2, n_labels=2") +
  theme(plot.title = element_text(size = 20, hjust = 0.3))

pxgb5
pxgb6

