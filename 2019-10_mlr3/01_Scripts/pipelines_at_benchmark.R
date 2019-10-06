library(paradox)
tn_rng_ps <- ParamSet$new(list(
    ParamInt$new("num.trees", lower = 100, upper = 1000),
    ParamInt$new("mtry", lower = 5, upper = 15)
))

tn_rng_ps

library(mlr3filters)
library(mlr3pipelines)

tsk_attr <- TaskClassif$new(id="attrition", backend = attrDT, target = "Attrition",
                            positive = "Yes")

lrn_rpart <- lrn("classif.rpart", predict_type = "prob")
lrn_xgboost <- lrn("classif.xgboost", predict_type = "prob")

lrn_ranger <- lrn("classif.ranger")
lrn_ranger$param_set$values = list(importance = "impurity")

filter = flt("importance", learner = lrn_ranger)

filter_xg = flt("importance", learner = lrn_xgboost )
filter_xg$calculate(tsk_attr)


filter$calculate(tsk_attr)
head(as.data.table(filter),10)

flt_gr_ranger <- po("filter", flt("importance", learner = lrn_ranger), filter.nfeat = 15)

gr_ranger <- flt_gr_ranger %>>% po("scale") %>>% po("encode") %>>% 
    mlr_pipeops$get("learner", learner = lrn_ranger)

gr_ranger
gr_ranger$plot(html=TRUE)

gr_ranger$train(tsk_attr)
gr_ranger
gr_ranger$state[1]

granger_lrn <- GraphLearner$new(gr_ranger)

granger_lrn

gr_xgb <- po("encode") %>>% po("scale") %>>%
    po("filter", flt("importance", learner=lrn_xgboost), filter.nfeat = 15) %>>%
    mlr_pipeops$get("learner", learner = lrn_xgboost)

gr_xgb
gr_xgb$plot(html=TRUE)

gr_xgb$train(tsk_attr)
gr_xgb

gr_xgb$state[3]

gxglrn <- GraphLearner$new(gr_xgb, predict_type = "prob")

tune_xg_ps <- ParamSet$new(list(
    ParamDbl$new("classif.xgboost.eta", lower = 0.01, upper = 0.3),
    ParamInt$new("classif.xgboost.nrounds", lower = 100, upper = 1000)
))

evals20 <- term("evals", n_evals = 20)
rcv5 <- rsmp("repeated_cv", folds = 5, repeats = 3)
cv3 <- rsmp("cv", folds = 3)
tuner = tnr("random_search")
meas_auc <- msr("classif.auc")


at_xgb = AutoTuner$new(
    learner = gxglrn,
    resampling = cv3,
    measures = meas_auc,
    tune_ps = tune_xg_ps,
    terminator = evals20,
    tuner = tuner
)

at_xgb$predict_type = "prob"

gxglrn

grid = benchmark_grid(
    task = tsk_attr,
    learner = list(at_xgb, gxglrn, lrn_rpart),
    resamplings = rsmp("cv", folds = 3)
)

future::plan("multiprocess")
library(tictoc)
store_models = TRUE
tic("start benchmark...")
bmr = benchmark(grid)
toc()

bmr$aggregate(measures)

tab = bmr$aggregate(measures)
ranks = tab[, .(learner_id, resampling_id, rank_train = rank(-auc_train), rank_test = rank(-auc_test)), by = task_id]
print(ranks)

ranks[, .(mrank_train = mean(rank_train), mrank_test = mean(rank_test)), 
      by = .(learner_id, resampling_id)][order(mrank_test)]


rng_tn_instance$archive(unnest = "params")[,c("num.trees", "mtry", "classif.auc")]

tab$resample_result
at_xgb

bmr$aggregate(measures)[,.(learner_id, auc_test)]

bmr$params

rcv3 <- rsmp("repeated_cv", folds = 3, repeats = 5)
learners <- c(at_xgb, gxglrn, lrn_rpart)
learners <- lapply(learners, lrn, predict_type="prob",
                   predict_sets = c("train", "test"))

resamplings <- c(rs_holdout, rcv3)
learners

design <- benchmark_grid(tsk_attr, learners, resamplings = cv3)
design

future::plan("multiprocess")
tic("benchmarking..")
attr_bm <- benchmark(design, store_models = TRUE)
toc()
attr_bm

measures <- list(
    msr("classif.auc", id = "auc_train", predict_sets = "train"),
    msr("classif.auc", id = "auc_test", predict_sets = "test")
)

attr_bm$params
attr_bm$aggregate(measures)
attr_bm$aggregate()
attr_bm$learners
attr_bm$unhashes
attr_bm$learners$learner[1](unnest = "Model")

mlr3misc::unnest(attr_bm$aggregate(params = TRUE), "params")[,.(learner_id, 
                                                                classif.ce,importance.filter.nfeat,classif.xgboost.eta,
                                                                classif.xgboost.nrounds)]


rr_xgb_at <- attr_bm$aggregate()[learner_id == "encode.scale.importance.classif.xgboost.tuned",
                                  resample_result][[1]]
rr_xgb_at
msr_acc = msr("classif.acc")

stackgraph = po("scale") %>>%
    list(po("learner_cv", lrn("classif.rpart")),
    po("learner_cv", lrn("classif.ranger"))) %>>%
    po("featureunion", id = "fu2") %>>% po("encode") %>>%
    lrn("classif.xgboost")



single_path_xgb = po("subsample") %>>% po("encode") %>>% lrn("classif.xgboost")
graph_bag_xgb = greplicate(single_path_xgb, n = 3) %>>%
    po("classifavg")

graph_bag_xgb$train(tsk_attr)
graph_bag_xgb
lrn_graph_bag_xgb = GraphLearner$new(graph_bag_xgb)
lrn_graph_bag_xgb$train(tsk_attr)
lrn_graph_bag_xgb
graph_bag_xgb_pred = lrn_graph_bag_xgb$predict_newdata(tsk_attr, new_attr)
graph_bag_xgb_pred$score(msr_acc)

stackgraph$plot(html=TRUE)
stackgraph
stackgraph$train(tsk_attr)
stackgraph

lrn_stackgraph = GraphLearner$new(stackgraph)
lrn_stackgraph$train(tsk_attr)

new_attr <- fread("00_Data/attrition_newdata.csv")
msr_ce = msr("classif.ce")
pred_stack = lrn_stackgraph$predict_newdata(tsk_attr, new_attr)
pred_stack$score(msr_ce)
