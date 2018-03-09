
# load packages, data =====================================

library(mice)
load('brfss15mo.RData')




# explore data ============================================

head(brfss15mo)
nrow(brfss15mo)
colSums(is.na(brfss15mo))
round(colMeans(is.na(brfss15mo)), 3)




# general idea ============================================

# say want to impute missing bmi

# create model to predict bmi

bmi_reg = lm(bmi ~ age + race + educ + income + sex, data=brfss15mo)
summary(bmi_reg)

# sample from sampling distribution of regression coefficients

coef(bmi_reg)
vcov(bmi_reg)

# obtain fitted values for all missing bmi through new regression equation

# add random variation with SD derived from model to each fitted value

summary(bmi_reg)$sigma

# run analysis with imputed data

# repeat process multiple times (say M)
# random sampling results in different data sets

# combine results across imputed analyses

# estimate = average of M estimates
# variance \approx average of variances + variance of averages




# statistical assumptions =================================

# requires data are "missing at random"

# probability of missing does not depend on the value of the missing data




# multiple imputations ====================================

imputed_data = mice(brfss15mo, m=5, maxit=3)

class(imputed_data)
head(imputed_data$data)
head(imputed_data$imp$income)

head(complete(imputed_data, action=1))
head(complete(imputed_data, action=2))
head(complete(imputed_data, action=3))

imputed_data$method




# "simple" analysis =======================================

imputed_model = with(data=imputed_data, expr=lm(bmi ~ age + race + educ + income + sex))
class(imputed_model)

summary(imputed_model)

summary(imputed_model$analyses[[1]])

results = pool(imputed_model)

summary(results)




# "complex" analysis ======================================

library(MatchIt)

imputed_list = lapply(1:5, function(i){
  
  mydat = complete(imputed_data, i)
  
  mydat$male = mydat$sex=='Male'
  matched = matchit(male ~ age + race + educ + income, data=mydat)
  match_data = match.data(matched)
  
  match_reg = lm(bmi ~ age + race + educ + income + sex, data=match_data)
  
  return(match_reg)
})

imputed_mira = as.mira(imputed_list)

results2 = pool(imputed_mira)
summary(results2)




# common questions ========================================

# Amount of missing data
# Less than 5% missing will not affect results much
# 5% - 20% is manageable
# More than 20% missing is problematic

# Number of imputations
# 5 - 10
# Or: equal to largest percent missing of all variables in data set