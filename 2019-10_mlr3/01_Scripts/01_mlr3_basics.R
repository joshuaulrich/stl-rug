library(data.table)
library(ggplot2)
library(ggthemes)
library(mlr3)
library(skimr)
library(pryr)
library(mlr3tuning)
library(mlr3learners)

vdt <- function(obj) {
  print(as.data.table(obj))
}

vw <- function(obj, key) {
  print(as.data.table(obj)[,.(key)])
}

vw(mlr_learners)

as.data.table(mlr_learners)[,.(key, packages)]

print(as.data.table(mlr_learners))

hrDT <- fread(here::here("00_Data/HR_comma_sep.csv"))
telcoDT <- fread(here::here("00_Data/WA_Fn-UseC_-HR-Employee-Attrition.csv"))

telcoDT
skim(hrDT)

table(hrDT$left)
table(hrDT$promotion_last_5years)
table(hrDT$Work_accident)


# notes
# target is 'left' --> should be factor
# Work_accident, promotion_last_5years should be factor
# salary --> factor

hrDT[,left := as.factor(ifelse(left == 1, "Yes", "No"))][
  ,Work_accident := as.factor(ifelse(Work_accident == 1, "Yes", "No"))
][
  ,promotion_last_5years := as.factor(ifelse(promotion_last_5years == 1, "Yes", "No"))
][
  ,salary := as.factor(salary)
]

# create task
hr_tsk <- TaskClassif$new(id = "hr", backend = hrDT, target = "left")
hr_tsk
hr_tsk$missings()

hr_tsk$feature_types
hr_tsk$backend
hr_tsk$class_names
hr_tsk$data()

as.data.table(mlr_learners)[,.(key, packages)]

formals(TaskClassif$public_methods$initialize)
formals(Learner$public_methods$initialize)
formals(Tuner$public_methods$initialize)

lrn_rpart <- lrn("classif.rpart", predict_type = "prob")

# split data train/test
set.seed(4411)
train.idx <- sample(seq_len(hr_tsk$nrow), 0.7 * hr_tsk$nrow)
test.idx <- setdiff(seq_len(hr_tsk$nrow), train.idx)

lrn_rpart

lrn_rpart$train(hr_tsk, row_ids = train.idx)

plot(lrn_rpart$model)
text(lrn_rpart$model)

lrn_rpart$timings

rpart_predict <- lrn_rpart$predict(hr_tsk, row_ids = test.idx)
rpart_predict
lrn_rpart$importance()

as.data.table(rpart_predict)
meas_ce <- msr("classif.ce")
meas_auc <- msr("classif.auc")
meas_acc <- msr("classif.acc")

rpart_predict$score(list(meas_ce, meas_auc, meas_acc))

lrn_ranger <- lrn("classif.ranger")

lrn_ranger$train(hr_tsk, row_ids = train.idx)
ranger_predict <- lrn_ranger$predict(hr_tsk, row_ids = test.idx)
ranger_predict$score(list(meas_ce, meas_auc, meas_acc))

lrn_dummy <- lrn("classif.featureless")
lrn_dummy$train(hr_tsk, row_ids = train.idx)
dummy_predict <- lrn_dummy$predict(hr_tsk, row_ids = test.idx)
dummy_predict$score(list(meas_ce, meas_auc, meas_acc))

lrn_glmnet <- lrn("classif.glmnet")
lrn_log <- lrn("classif.log_reg")

lrn_log$train(hr_tsk, train.idx)
log_predict <- lrn_log$predict(hr_tsk, test.idx)
log_predict$score(list(meas_ce, meas_acc))



attrDT <- as.data.table(rsample::attrition)

attrDT[,1:6]
attrDT[,7:12]
attrDT[,13:18]
attrDT[,19:24]
attrDT[,25:29]
attrDT[,30:31]
