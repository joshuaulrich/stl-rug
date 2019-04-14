#----------------------------------------------------------------------------------------------------------#
# The below function can be used to generate random nonlinear response data for testing the ability of
# various machine learning techniques to predict complex relationships.
#
# nonlin_fun: Friedman's function, Mirsha's Bird function, an exponential function, and a linear function.
# n: Sample size
# p_null: a number of "extra" x variables added into the returned X data frame which do NOT affect
#          the response variable
# sigma: The amount of variability in the data, this value would serve as a lower bound on the predictive
#         ablity of ANY model as it repsensnts unexplainable measurment error.
#----------------------------------------------------------------------------------------------------------#

Generate_Data <- function(nonlin_f, n, p_null, sigma)
{
  if(nonlin_f == "Friedman"){
    p <- 5 + p_null
    X <- matrix(runif(n * p), nrow = n, ncol = p)
    y <- 10 * sin(pi * X[, 1] * X[, 2]) + 20 * (X[, 3] - .5)^2 + 10 * X[, 4] + 5 * X[, 5] + rnorm(n, 0, sigma)
  }
  
  if(nonlin_f == "Mirsha"){
    p <- 2 + p_null
    X <- matrix(runif(n * p), nrow = n, ncol = p)
    X[,1] <- runif(n,-10,0)
    X[,2] <- runif(n,-6.5,0)
    y <- sin(X[,2])*exp((1-cos(X[,1]))^2) + cos(X[,1])*exp((1-sin(X[,2]))^2) + (X[,1] - X[,2])^2 + rnorm(n, 0, sigma)
  }
  
  if(nonlin_f == "Exp"){
    p <- 3 + p_null
    X <- matrix(runif(n * p), nrow = n, ncol = p)
    y <- 100*(exp(-2/(X[,1]^1.75)) + exp(-2/(X[,1]^1.5)) + exp(-2/(X[,1]^1.25))) + rnorm(n, 0, sigma)
  }
  
  if(nonlin_f == "Linear"){
    p <- 6 + p_null
    X <- matrix(runif(n * p), nrow = n, ncol = p)
    y <- X[,1] + X[,2] + X[,3] + X[,4] + X[,5] + X[,6] + rnorm(n, 0, sigma)
    
  }
  
  return(data.frame(y, X))
}
