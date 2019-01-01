setwd("/home/john/Dropbox/Rprojects/RNN_TimeSeries")

#https://tensorflow.rstudio.com/blog/time-series-forecasting-with-recurrent-neural-networks.html
dir.create("jena_climate", recursive = TRUE)
download.file(
  "https://s3.amazonaws.com/keras-datasets/jena_climate_2009_2016.csv.zip",
  paste0(getwd(),"/jena_climate/jena_climate_2009_2016.csv.zip")
)
unzip(
  paste0(getwd(),"/jena_climate/jena_climate_2009_2016.csv.zip"),
  exdir = paste0(getwd(),"/jena_climate")
)


#Until now, the only sequence data we’ve covered has been text data, such as the IMDB dataset and the Reuters dataset.
#But sequence data is found in many more problems than just language processing. In all the examples in this section,
#you’ll play with a weather timeseries dataset recorded at the Weather Station at the Max Planck Institute for
#Biogeochemistry in Jena, Germany.

#In this dataset, 14 different quantities (such air temperature, atmospheric pressure, humidity, wind direction,
#and so on) were recorded every 10 minutes, over several years. The original data goes back to 2003, but this
#example is limited to data from 2009–2016. This dataset is perfect for learning to work with numerical time series.
#You’ll use it to build a model that takes as input some data from the recent past (a few days’ worth of data points)
#and predicts the air temperature 24 hours in the future.

library(tibble)
library(readr)

data_dir <- paste0(getwd(),"/jena_climate")
fname <- file.path(data_dir, "jena_climate_2009_2016.csv")
data <- read_csv(fname)

glimpse(data)

#Here is the plot of temperature (in degrees Celsius) over time.
#On this plot, you can clearly see the yearly periodicity of temperature.

library(ggplot2)
ggplot(data, aes(x = 1:nrow(data), y = `T (degC)`)) + geom_line()


#Here is a more narrow plot of the first 10 days of temperature data (see figure 6.15).
#Because the data is recorded every 10 minutes, you get 144 data points per day.

6*24*10
ggplot(data[1:1440,], aes(x = 1:1440, y = `T (degC)`)) + geom_line()

#On this plot, you can see daily periodicity, especially evident for the last 4 days.
#Also note that this 10-day period must be coming from a fairly cold winter month.

#If you were trying to predict average temperature for the next month given a few months of past data,
#the problem would be easy, due to the reliable year-scale periodicity of the data. 
#But looking at the data over a scale of days, the temperature looks a lot more chaotic. 
#Is this time series predictable at a daily scale? Let’s find out.

#=======================================================================================================#
#============================================= PREPARING THE DATA ======================================#
#=======================================================================================================#

#The exact formulation of the problem will be as follows: given data going as far back as lookback
#timesteps (a timestep is 10 minutes) and sampled every steps timesteps, can you predict the temperature
#in delay timesteps? You’ll use the following parameter values:

# lookback = 1440 — Observations will go back 10 days.
# steps = 6 — Observations will be sampled at one data point per hour.
# delay = 144 — Targets will be 24 hours in the future.

#To get started, you need to do two things:

#Preprocess the data to a format a neural network can ingest. This is easy: the data is already numerical,
#so you don’t need to do any vectorization. But each time series in the data is on a different scale
#(for example, temperature is typically between -20 and +30, but atmospheric pressure, measured in mbar,
#is around 1,000). You’ll normalize each time series independently so that they all take small values
#on a similar scale.

#Write a generator function that takes the current array of float data and yields batches of data from
#the recent past, along with a target temperature in the future. Because the samples in the dataset are 
#highly redundant (sample N and sample N + 1 will have most of their timesteps in common), it would be
#wasteful to explicitly allocate every sample. Instead, you’ll generate the samples on the fly using
#the original data.


#=======================================================================================================#
#================================= NOTE: Understanding generator functions =============================#
#=======================================================================================================#

#A generator function is a special type of function that you call repeatedly to obtain a sequence of 
#values from. Often generators need to maintain internal state, so they are typically constructed by
#calling another yet another function which returns the generator function (the environment of the
#function which returns the generator is then used to track state). For example, the sequence_generator() 
#function below returns a generator function that yields an infinite sequence of numbers:

sequence_generator <- function(start) {
  value <- start - 1
  function() {
    value <<- value + 1
    value
  }
}

gen <- sequence_generator(1)

gen()
gen()

#The current state of the generator is the value variable that is defined outside of the function. 
#Note that superassignment (<<-) is used to update this state from within the function. 
#Generator functions can signal completion by returning the value NULL. However, generator functions 
#passed to Keras training methods (e.g. fit_generator()) should always return values infinitely 
#(the number of calls to the generator function is controlled by the epochs and steps_per_epoch parameters).

#First, you’ll convert the R data frame which we read earlier into a matrix of floating point values 
#(we’ll discard the first column which included a text timestamp):

data <- data.matrix(data[,-1])
#You’ll then preprocess the data by subtracting the mean of each time series and dividing by the 
#standard deviation. You’re going to use the first 200,000 timesteps as training data, so compute the 
#mean and standard deviation for normalization only on this fraction of the data.

train_data <- data[1:200000,]
mean <- apply(train_data, 2, mean)
std <- apply(train_data, 2, sd)
data <- scale(data, center = mean, scale = std)

#The code for the data generator you’ll use is below. It yields a list (samples, targets), where samples
#is one batch of input data and targets is the corresponding array of target temperatures. It takes the 
#following arguments:

# data — The original array of floating-point data, which you normalized in listing 6.32.
# lookback — How many timesteps back the input data should go.
# delay — How many timesteps in the future the target should be.
# min_index and max_index — Indices in the data array that delimit which timesteps to draw from. 
#       This is useful for keeping a segment of the data for validation and another for testing.
# shuffle — Whether to shuffle the samples or draw them in chronological order.
# batch_size — The number of samples per batch.
# step — The period, in timesteps, at which you sample data. You’ll set it 6 in order to draw one
#      data point every hour.

generator <- function(data, lookback, delay, min_index, max_index,
                      shuffle = FALSE, batch_size = 128, step = 6) {
  if (is.null(max_index))
    max_index <- nrow(data) - delay - 1
  i <- min_index + lookback
  function() {
    if (shuffle) {
      rows <- sample(c((min_index+lookback):max_index), size = batch_size)
    } else {
      if (i + batch_size >= max_index)
        i <<- min_index + lookback
      rows <- c(i:min(i+batch_size, max_index))
      i <<- i + length(rows)
    }
    
    samples <- array(0, dim = c(length(rows), 
                                lookback / step,
                                dim(data)[[-1]]))
    targets <- array(0, dim = c(length(rows)))
    
    for (j in 1:length(rows)) {
      indices <- seq(rows[[j]] - lookback, rows[[j]], 
                     length.out = dim(samples)[[2]])
      samples[j,,] <- data[indices,]
      targets[[j]] <- data[rows[[j]] + delay,2]
    }            
    
    list(samples, targets)
  }
}

generator_test <- function(data, lookback, delay, min_index, max_index,
                           shuffle = FALSE, batch_size = 128, step = 6) {
  if (is.null(max_index))
    max_index <- nrow(data) - delay - 1
  i <- min_index + lookback
  function() {
    if (shuffle) {
      rows <- sample(c((min_index+lookback):max_index), size = batch_size)
    } else {
      if (i + batch_size >= max_index)
        i <<- min_index + lookback
      rows <- c(i:min(i+batch_size, max_index))
      i <<- i + length(rows)
    }
    
    samples <- array(0, dim = c(length(rows), 
                                lookback / step,
                                dim(data)[[-1]]))
    targets <- array(0, dim = c(length(rows)))
    
    for (j in 1:length(rows)) {
      indices <- seq(rows[[j]] - lookback, rows[[j]], 
                     length.out = dim(samples)[[2]])
      samples[j,,] <- data[indices,]
    }            
    list(samples)
  }
}

#The i variable contains the state that tracks next window of data to return, so it is updated using 
#superassignment (e.g. i <<- i + length(rows)).

#Now, let’s use the abstract generator function to instantiate three generators: one for training,
#one for validation, and one for testing. Each will look at different temporal segments of the original 
#data: the training generator looks at the first 200,000 timesteps, the validation generator looks at 
#the following 100,000, and the test generator looks at the remainder.

lookback <- 1440
step <- 6
delay <- 144
batch_size <- 128

train_gen <- generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 1,
  max_index = 200000,
  shuffle = TRUE,
  step = step, 
  batch_size = batch_size
)

val_gen = generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 200001,
  max_index = 300000,
  step = step,
  batch_size = batch_size
)

test_gen <- generator_test(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 300001,
  max_index = NULL,
  step = step,
  batch_size = batch_size
)

# How many steps to draw from val_gen in order to see the entire validation set
val_steps <- (300000 - 200001 - lookback) / batch_size

# How many steps to draw from test_gen in order to see the entire test set
test_steps <- (nrow(data) - 300001 - lookback) / batch_size



#=======================================================================================================#
#============================= A COMMON-SENSE, NON-MACHINE-LEARNING BASELINE ===========================#
#=======================================================================================================#

#Before you start using black-box deep-learning models to solve the temperature-prediction problem, 
#let’s try a simple, common-sense approach. It will serve as a sanity check, and it will establish a 
#baseline that you’ll have to beat in order to demonstrate the usefulness of more-advanced 
#machine-learning models. Such common-sense baselines can be useful when you’re approaching a new
#problem for which there is no known solution (yet). A classic example is that of unbalanced 
#classification tasks, where some classes are much more common than others. If your dataset contains
#90% instances of class A and 10% instances of class B, then a common-sense approach to the classification
#task is to always predict “A” when presented with a new sample. Such a classifier is 90% accurate overall,
#and any learning-based approach should therefore beat this 90% score in order to demonstrate usefulness.
#Sometimes, such elementary baselines can prove surprisingly hard to beat.

#In this case, the temperature time series can safely be assumed to be continuous
#(the temperatures tomorrow are likely to be close to the temperatures today) as well as periodical
#with a daily period. Thus a common-sense approach is to always predict that the temperature 24 hours
#from now will be equal to the temperature right now. Let’s evaluate this approach, using the
#mean absolute error (MAE) metric:

#mean(abs(preds - targets))

#Here’s the evaluation loop.

library(keras)
evaluate_naive_method <- function() {
  batch_maes <- c()
  for (step in 1:val_steps) {
    c(samples, targets) %<-% val_gen()
    preds <- samples[,dim(samples)[[2]],2]
    mae <- mean(abs(preds - targets))
    batch_maes <- c(batch_maes, mae)
  }
  print(mean(batch_maes))
}

evaluate_naive_method()

#This yields an MAE of 0.29. Because the temperature data has been normalized to be centered on 0 
#and have a standard deviation of 1, this number isn’t immediately interpretable. It translates to
#an average absolute error of 0.29 x temperature_std degrees Celsius: 2.57˚C.

celsius_mae <- 0.27752 * std[[2]]
celsius_mae
#That’s a fairly large average absolute error. Now the game is to use your knowledge of deep learning
#to do better.

#=======================================================================================================#
#====================================== A BASIC MACHINE-LEARNING APPROACH ==============================#
#=======================================================================================================#

#In the same way that it’s useful to establish a common-sense baseline before trying machine-learning
#approaches, it’s useful to try simple, cheap machine-learning models
#(such as small, densely connected networks) before looking into complicated and computationally 
#expensive models such as RNNs. This is the best way to make sure any further complexity you throw at
#the problem is legitimate and delivers real benefits.

#The following listing shows a fully connected model that starts by flattening the data and then runs it
#through two dense layers. Note the lack of activation function on the last dense layer, which is typical
#for a regression problem. You use MAE as the loss. Because you evaluate on the exact same data and
#with the exact same metric you did with the common-sense approach, the results will be directly comparable.

library(keras)

model <- keras_model_sequential() %>% 
  layer_flatten(input_shape = c(lookback / step, dim(data)[-1])) %>% 
  layer_dense(units = 32, activation = "relu") %>% 
  layer_dense(units = 1)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)

history <- model %>% fit_generator(
  train_gen,
  steps_per_epoch = 100,
  epochs = 20,
  validation_data = val_gen,
  validation_steps = val_steps
)

saveRDS(history,file = "W_ANN.rds")
Weather_ANN <- readRDS("W_ANN.rds")

#Display the loss curves for validation and training
plot(Weather_ANN)

predict_generator(model,test_gen,test_steps)
#Some of the validation losses are close to the no-learning baseline, but not reliably. 
#This goes to show the merit of having this baseline in the first place: it turns out to be not easy
#to outperform. Your common sense contains a lot of valuable information that a machine-learning model
#doesn’t have access to.

#You may wonder, if a simple, well-performing model exists to go from the data to the targets 
#(the common-sense baseline), why doesn’t the model you’re training find it and improve on it? 
#Because this simple solution isn’t what your training setup is looking for. The space of models in 
#which you’re searching for a solution – that is, your hypothesis space – is the space of all possible 
#two-layer networks with the configuration you defined. These networks are already fairly complicated. 
#When you’re looking for a solution with a space of complicated models, the simple, well-performing 
#baseline may be unlearnable, even if it’s technically part of the hypothesis space. That is a pretty 
#significant limitation of machine learning in general: unless the learning algorithm is hardcoded to
#look for a specific kind of simple model, parameter learning can sometimes fail to find a simple solution
#to a simple problem.

#=======================================================================================================#
#========================================== A FIRST RECURRENT BASELINE =================================#
#=======================================================================================================#

#The first fully connected approach didn’t do well, but that doesn’t mean machine learning isn’t 
#applicable to this problem. The previous approach first flattened the time series, which removed the
#notion of time from the input data. Let’s instead look at the data as what it is: a sequence, where
#causality and order matter. You’ll try a recurrent-sequence processing model – it should be the 
#perfect fit for such sequence data, precisely because it exploits the temporal ordering of data points,
#unlike the first approach.

#Instead of the LSTM layer introduced in the previous section, you’ll use the GRU layer, developed by
#Chung et al. in 2014. Gated recurrent unit (GRU) layers work using the same principle as LSTM, but 
#they’re somewhat streamlined and thus cheaper to run (although they may not have as much representational
#power as LSTM). This trade-off between computational expensiveness and representational power is seen 
#everywhere in machine learning.

model <- keras_model_sequential() %>% 
  layer_gru(units = 32, input_shape = list(NULL, dim(data)[[-1]]),dropout = .25,recurrent_dropout = .2) %>% 
  layer_dense(units = 1)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)

history <- model %>% fit_generator(
  train_gen,
  steps_per_epoch = 1000,
  epochs = 50,
  validation_data = val_gen,
  validation_steps = val_steps
)

plot(history)

#The results are plotted below. Much better! You can significantly beat the common-sense baseline, 
#demonstrating the value of machine learning as well as the superiority of recurrent networks compared 
#to sequence-flattening dense networks on this type of task.

#The new validation MAE of ~0.265 (before you start significantly overfitting) translates to a mean 
#absolute error of 2.35˚C after denormalization. That’s a solid gain on the initial error of 2.57˚C,
#but you probably still have a bit of a margin for improvement.

#=======================================================================================================#
#============================ USING RECURRENT DROPOUT TO FIGHT OVERFITTING =============================#
#=======================================================================================================#

#It’s evident from the training and validation curves that the model is overfitting: the training and
#validation losses start to diverge considerably after a few epochs. You’re already familiar with a 
#classic technique for fighting this phenomenon: dropout, which randomly zeros out input units of a
#layer in order to break happenstance correlations in the training data that the layer is exposed to. 
#But how to correctly apply dropout in recurrent networks isn’t a trivial question. It has long been 
#known that applying dropout before a recurrent layer hinders learning rather than helping with
#regularization. In 2015, Yarin Gal, as part of his PhD thesis on Bayesian deep learning, determined 
#the proper way to use dropout with a recurrent network: the same dropout mask (the same pattern of 
#dropped units) should be applied at every timestep, instead of a dropout mask that varies randomly from
#timestep to timestep. What’s more, in order to regularize the representations formed by the recurrent 
#gates of layers such as layer_gru and layer_lstm, a temporally constant dropout mask should be 
#applied to the inner recurrent activations of the layer (a recurrent dropout mask). Using the same 
#dropout mask at every timestep allows the network to properly propagate its learning error through 
#time; a temporally random dropout mask would disrupt this error signal and be harmful to the learning process.

#Yarin Gal did his research using Keras and helped build this mechanism directly into Keras recurrent
#layers. Every recurrent layer in Keras has two dropout-related arguments: dropout, a float specifying 
#the dropout rate for input units of the layer, and recurrent_dropout, specifying the dropout rate of 
#the recurrent units. Let’s add dropout and recurrent dropout to the layer_gru and see how doing so
#impacts overfitting. Because networks being regularized with dropout always take longer to fully 
#converge, you’ll train the network for twice as many epochs.

model <- keras_model_sequential() %>% 
  layer_gru(units = 32, dropout = 0.2, recurrent_dropout = 0.2,
            input_shape = list(NULL, dim(data)[[-1]])) %>% 
  layer_dense(units = 1)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)

history <- model %>% fit_generator(
  train_gen,
  steps_per_epoch = 500,
  epochs = 40,
  validation_data = val_gen,
  validation_steps = val_steps
)

#The plot below shows the results. Success! You’re no longer overfitting during the first 20 epochs.
#But although you have more stable evaluation scores, your best scores aren’t much lower than they were previously.


#=======================================================================================================#
#==================================== STACKING RECURRENT LAYERS ========================================#
#=======================================================================================================#

#Because you’re no longer overfitting but seem to have hit a performance bottleneck, you should consider
#increasing the capacity of the network. Recall the description of the universal machine-learning 
#workflow: it’s generally a good idea to increase the capacity of your network until overfitting 
#becomes the primary obstacle (assuming you’re already taking basic steps to mitigate overfitting, 
#such as using dropout). As long as you aren’t overfitting too badly, you’re likely under capacity.

#Increasing network capacity is typically done by increasing the number of units in the layers or 
#adding more layers. Recurrent layer stacking is a classic way to build more-powerful recurrent
#networks: for instance, what currently powers the Google Translate algorithm is a stack of seven 
#large LSTM layers – that’s huge.

#To stack recurrent layers on top of each other in Keras, all intermediate layers should return their
#full sequence of outputs (a 3D tensor) rather than their output at the last timestep. This is done by 
#specifying return_sequences = TRUE.


model <- keras_model_sequential() %>% 
  layer_gru(units = 32, 
            dropout = 0.1, 
            recurrent_dropout = 0.5,
            return_sequences = TRUE,
            input_shape = list(NULL, dim(data)[[-1]])) %>% 
  layer_gru(units = 64, activation = "relu",
            dropout = 0.1,
            recurrent_dropout = 0.5) %>% 
  layer_dense(units = 1)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)

history <- model %>% fit_generator(
  train_gen,
  steps_per_epoch = 500,
  epochs = 40,
  validation_data = val_gen,
  validation_steps = val_steps
)

saveRDS(history,file = "W_LSTM.rds")
Weather_LSTM <- readRDS("W_LSTM.rds")
plot(Weather_LSTM)

0.27752 * std[[2]]

#The figure below shows the results. You can see that the added layer does improve the results a bit,
#though not significantly. You can draw two conclusions:

#---Because you’re still not overfitting too badly, you could safely increase the size of your layers in a
#quest for validation-loss improvement. This has a non-negligible computational cost, though.

#---Adding a layer didn’t help by a significant factor, so you may be seeing diminishing returns from 
#increasing network capacity at this point.


