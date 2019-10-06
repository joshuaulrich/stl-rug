
design = benchmark_grid(
  tasks = hr_tsk,
  learners = list(lrn_dummy, lrn_log, lrn_rpart, lrn_ranger),
  resamplings = rsmp("holdout")
)

design

bmr = benchmark(design)
bmr

learners = c("classif.featureless", "classif.rpart", "classif.ranger", "classif.log_reg")
learners = lapply(learners, lrn,
                  predict_type = "prob",
                  predict_sets = c("train", "test"))

learners
resamplings = rsmp("cv", folds = 3)
design = benchmark_grid(hr_tsk, learners, resamplings)
print(design)

bmr = benchmark(design)

measures = list(
  msr("classif.auc", id = "auc_train", predict_sets = "train"),
  msr("classif.auc", id = "auc_test")
)

bmr$aggregate(measures)
