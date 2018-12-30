# Script for running code in the example presented in the slides.  Can be run on CPU
library(keras)
library(dplyr)

TS_generator <- function(data, lookback, min_index=1, max_index,
                         batch_size = 4, shuffle=FALSE){
  i <- min_index + lookback
  function(){
    if(shuffle){
      rows <- sample(c((min_index+lookback):max_index), size = batch_size)
    }else{
      if (i + batch_size >= max_index){i <<- min_index + lookback}
      
      rows <- c(i:min(i+batch_size-1, max_index))
      i <<- i + length(rows)
    }
    #initialize output objects
    samples <- array(0, dim = c(length(rows),lookback,1))
    targets <- array(0, dim = length(rows))    #one target for each sample
    
    for(j in 1:length(rows)){
      indices <- seq(rows[j] - lookback, rows[j]-1)
      samples[j,,] <- data[indices]
      targets[j] <- data[rows[j]]
    }            
    
    list(samples, targets)
  }
}

TS_generator_test <- function(data, lookback, min_index=1, max_index,
                         batch_size = 4, shuffle=FALSE){
  i <- min_index + lookback
  function(){
    if(shuffle){
      rows <- sample(c((min_index+lookback):max_index), size = batch_size)
    }else{
      if (i + batch_size >= max_index){i <<- min_index + lookback}
      
      rows <- c(i:min(i+batch_size-1, max_index))
      i <<- i + length(rows)
    }
    #initialize output objects
    samples <- array(0, dim = c(length(rows),lookback,1))
    targets <- array(0, dim = length(rows))    #one target for each sample
    
    for(j in 1:length(rows)){
      indices <- seq(rows[j] - lookback, rows[j]-1)
      samples[j,,] <- data[indices]
      targets[j] <- data[rows[j]]
    }            
    
    list(samples)
  }
}

# Generate 10 cycles of sin(x) + noise
n_seq <- 2000
x <- seq(0,10*2*pi,length.out = n_seq)
truth <- sin(x)
data <- truth + rnorm(n_seq,mean=0,sd=.25) %>% as.matrix(ncol=1)
plot(x,data)

#data <- rnorm(3000) %>% as.matrix
train_gen <- TS_generator(data,lookback = 100,
                          min_index = 1,max_index = 1100,
                          batch_size = 8,shuffle = T)
val_gen <- TS_generator(data,lookback = 100,
                          min_index = 1101,max_index = 1500,
                          batch_size = 8,shuffle = T)


############## RNN with dropout
model1 <- keras_model_sequential() %>% 
  layer_simple_rnn(units = 16,
                   return_sequences = TRUE,
                   dropout = .2, recurrent_dropout = .3,
                   input_shape = list(NULL, 1)) %>% 
  layer_simple_rnn(units = 8) %>% 
  layer_dense(units = 1)

model1 %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mse")

summary(model1)

RNNfit <- model1 %>% fit_generator(
  train_gen,
  steps_per_epoch = 125,
  epochs = 40,
  validation_data = val_gen,
  validation_steps = 50
)

plot(RNNfit)
saveRDS(RNNfit,"RNNfit.rds")


### LSTM
############## add dropout
model2 <- keras_model_sequential() %>% 
  layer_lstm(units = 16,
                   return_sequences = TRUE,
                   dropout = .2, recurrent_dropout = .3,
                   input_shape = list(NULL, 1)) %>% 
  layer_lstm(units = 8) %>% 
  layer_dense(units = 1)

model2 %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mse"
)

summary(model2)

LSTMfit <- model2 %>% fit_generator(
  train_gen,
  steps_per_epoch = 125,
  epochs = 40,
  validation_data = val_gen,
  validation_steps = 50
)

plot(LSTMfit)
saveRDS(LSTMfit,"LSTMfit.rds")

############
Validation_Loss <- data.frame(epoch = rep(1:40,times=2),
                              Loss = c(RNNfit$metrics$val_loss,LSTMfit$metrics$val_loss),
                              Method = rep(c("RNN","LSTM"),each=40))

ggplot(data = Validation_Loss, aes(x = epoch,  y = Loss, color = Method)) +
  geom_point() +
  geom_smooth() + 
  geom_hline(yintercept=.0625, linetype="dashed", color = "black")




test_gen <- TS_generator_test(data,lookback = 100,
                              min_index = 1500-100,max_index = 2000,
                              batch_size = 1,shuffle = F)

pred <- predict_generator(model2,test_gen,500)

plot(x[1501:2000],data[(1501):2000],type="p",xlab="x",ylab="data")
lines(x[1501:2000],sin(x[1501:2000]),lwd=3,col="blue")
points(x[1501:2000],pred,col="red")







