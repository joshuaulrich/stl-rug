library(dplyr)
library(knitr)
library(xtable)
library(ggplot2)
library(iml)
library(randomForest)
library(gridExtra)

#install.packages("iml")  # CRAN
#devtools::install_github("christophM/iml") # Development
library(iml)

# Data here: archive.ics.uci.edu/ml/datasets/Bike+Sharing+Dataset
Bike <- read.csv("..../Bike-Sharing-Dataset/hour.csv")
Bike <- Bike %>% 
  select(cnt,              # Number of Rentals, the Response
         yr,               # Year (0: 2011, 1: 2012)
         mnth,             # Month (1 to 12)
         hr,               # Hour (0 to 23)
         holiday,          # Whether day is holiday or not 
         weekday,          # Day of the week, 0 = Sunday
         workingday,       # 1 if neither weekend nor holiday.
         weathersit,       # Ordinal weather indicator
         temp,             # Standardized Temperature
         hum,              # Humidity divided to 100
         atemp,            # Standardized Apparent Temperature
         windspeed) %>%    # Normalized wind speed
rename(Count = cnt,Year = yr, Month = mnth,Hour = hr,
       Holiday = holiday,Weekday = weekday,Workday = workingday,
       Weather = weathersit,Temp = temp,Humidity = hum,         
       AppTemp = atemp,Wind_Speed = windspeed)
Bike$Holiday <- factor(Bike$Holiday)
Bike$Weekday <- ordered(Bike$Weekday)
Bike$Workday <- factor(Bike$Workday)
Bike$Weather <- ordered(Bike$Weather)

## Build a Super Cool ML Predictor
Bike.Test  <- Bike %>% filter(Year==1 & Month == 12)
Bike.Train <- Bike %>% filter(!(Year==1 & Month == 12))
rf <- randomForest(Count ~ ., data = Bike.Train, ntree = 500)

# Build a prediction dataframe
PredDF <- data.frame(Test_Y = Bike.Test$Count,
                     Predictions = predict(rf,newdata = Bike.Test))

# Look at those awesome predicdictions
ggplot(PredDF,aes(x=Test_Y, y=Predictions)) +
  geom_point() + ylab("Test Predictions") + 
  xlab("Test Values") + 
  geom_abline(intercept = 0,slope = 1) + 
  theme_bw()

# Fit model on all data and build iml prediction object
rf <- randomForest(Count ~ ., data = Bike, ntree = 500)

# The prediction object needs objects for the features and targes variables
X <- Bike %>% select(-Count)
Y <- Bike %>% select(Count)

# This is the core prediction object used for all subsequent steps
Pred_Obj <- Predictor$new(rf, data = X, y = Y)

# Some functions have a parallel backend
library(doParallel)
cl = makeForkCluster(6)
registerDoParallel(cl)

# Variable importance plot
VarImp <- FeatureImp$new(Pred_Obj,
                         loss = "rmse",  #loss function used, I like RMSE because it is on the same scale as the data
                         parallel = TRUE,
                         n.repetitions = 30)
VarImp$plot()


## PDP - Time of Day
PDP <- FeatureEffect$new(Pred_Obj,feature = "Hour",
                         method = "pdp",grid.size = 24)
PDP$plot()

PDP <- FeatureEffect$new(Pred_Obj,feature = "AppTemp",
                         method = "pdp",grid.size = 50)
PDP$plot()



###################################################################
## ICE Plot: Daily Dataset
Bike_day <- read.csv("..../Bike-Sharing-Dataset/day.csv")
Bike_day <- Bike_day %>% select(cnt,
                                yr,
                                mnth,
                                holiday,
                                weekday,
                                workingday,
                                weathersit,
                                temp,
                                hum,
                                atemp,
                                windspeed)%>% 
  rename(Count = cnt,Year = yr, Month = mnth,
         Holiday = holiday,Weekday = weekday,Workday = workingday,
         Weather = weathersit,Temp = temp,Humidity = hum,         
         AppTemp = atemp,Wind_Speed = windspeed)
Bike_day$Holiday <- factor(Bike_day$Holiday)
Bike_day$Weekday <- ordered(Bike_day$Weekday)
Bike_day$Workday <- factor(Bike_day$Workday)
Bike_day$Weather <- ordered(Bike_day$Weather)


rf_day <- randomForest(Count ~ ., data = Bike_day, ntree = 500)
X <- Bike_day %>% select(-Count)
Y <- Bike_day %>% select(Count)
Pred_Obj_day <- Predictor$new(rf_day, data = X, y = Y)

ICE_temp <- FeatureEffect$new(Pred_Obj_day,feature = "AppTemp",
                              method = "ice",grid.size = 50)

ICE_wind <- FeatureEffect$new(Pred_Obj_day,feature = "Wind_Speed",
                              method = "ice",grid.size = 50)

Temp_plot <- ICE_temp$plot()
Wind_plot <- ICE_wind$plot()

grid.arrange(Temp_plot, Wind_plot , ncol=2)
###################################################################


## ICE Plot: Useless For Hourly Data
ICE <- FeatureEffect$new(Pred_Obj,feature = "AppTemp",
                         method = "ice",grid.size = 50)
ICE$plot()


## ICE Plot with PDP overlay
ICE_plus_PDP <- FeatureEffect$new(Pred_Obj,feature = "AppTemp",
                                  method =  "pdp+ice",grid.size = 50)
ICE_plus_PDP$plot()

## Interesting Take:  ICE Plot Aggregation
# This allows us to plot a smaller number of lines which are aggregated by another variable we choose
ICE_Results <- ICE$results  #Extract values
head(ICE_Results)

ICE_Results$Month <- as.factor(Bike$Month[ICE_Results$.id])

ICE_Agg <- ICE_Results %>% 
  group_by(Month,AppTemp) %>% 
  summarise(MeanCount = mean(.y.hat))


ggplot(ICE_Agg,aes(x=AppTemp,y=MeanCount,color=Month)) +
  geom_line()



## ALE Plot: Slightly Different than PDP! 
ALE <- FeatureEffect$new(Pred_Obj,feature = "AppTemp",
                         method = "ale",grid.size = 50)
ALE$plot()

# Categorical Predictors 
CatPred <- FeatureEffect$new(Pred_Obj,feature = "Weekday")
CatPred$plot()


## Surrogate Tree Visualization
SurTree = TreeSurrogate$new(Pred_Obj, maxdepth = 2)
plot(SurTree)

## Second Order ALE Plot
library(ALEPlot)
yhat <- function(X.model, newdata){
  as.numeric(predict(X.model, newdata))}
X <- Bike %>% select(-Count)
names(X)
# J = c(2,3) will plot Month and Hour

## Second Order ALE Plot: Time vs Month
ALEPlot(X, rf,pred.fun=yhat,J=c(3,2), K=50,NA.plot = TRUE)



