###
# this script goes some basics of using
# Louis Aslett's Homomorphic Encryption library
# using the cipher of Fan and Vercauteren
###

#load the library
library("HomomorphicEncryption")
#built on a C library
#uses a particular cryptosystem
#this is Fan and Vercauteren
p <- pars("FandV")
print(p)

#generate a key
#this is really an asymmetric pair
#private k$pk and secret k$sk
k <- keygen(p)
print(k)

#encrypt a couple vectors
c1 <- enc(k$pk, c(42,34))
c2 <- enc(k$pk, c(7,5))

#the data is encrypted
print(c2)
#working with a special data type
print(typeof(c2))


#can add, multiply, inner product
#R syntax is the same
cres1 <- c1 + c2
cres2 <- c1 * c2
cres3 <- c1 %*% c2

#decrypt and get correct answers
dec(k$sk, cres1)
dec(k$sk, cres2)
dec(k$sk, cres3)

#some new types
typeof(enc(k$pk, 5))
typeof(enc(k$pk, c(4,5)))
typeof(c(1,2,5))

#vector like but not an atomic vector
vectorLike <- enc(k$pk, c(42,34))
#can get length for example
length(vectorLike)
#and slice as we would a vector
dec(k$sk,vectorLike[1]+vectorLike[2])
#this doesn't work
enc(k$pk, 5.5)

#load the Titanic raw data
load("titanic.raw.rdata")
#what's in it?
titanic.raw[1:5,]

#build a basic logreg model
basicLogReg <- glm(
  Survived ~ Class + Sex + Age,
  data=titanic.raw,
  family=binomial(link="logit")
)

#clear denoms -> all integers
denom <- 1000
#the model data is  just its coefficients
encModel <- enc(
  k$pk,
  floor(
    denom*basicLogReg$coefficients
  )
)

#this is the data of my model now
print(encModel)
print(typeof(encModel))

#encrypt a new observation, now I want a score
exampleObs <- enc(k$pk,c(1,1,0,0,1,0))
living <- enc(k$pk,c(1,1,0,0,0,1))
dying <- enc(k$pk,c(1,0,1,0,1,0))

#this is my observation now
print(exampleObs)
print(typeof(exampleObs))

plain_odds <- function(obs,coeffs,sk,denom){
  innerProd <- dec(sk,obs %*% coeffs)
  decLogOdds <- (1/denom)*innerProd
  return(exp(decLogOdds)/(1+exp(decLogOdds)))
}

print(plain_odds(exampleObs,encModel,k$sk,denom))
print(plain_odds(living,encModel,k$sk,denom))
print(plain_odds(dying,encModel,k$sk,denom))

random_passenger <- function(pubKey){
  #1 just means include the intercept term
  intercept <- c(1)
  #random one-hot class indicator
  class <- rep(0,4-1)
  class[(4-1)*runif(1)]<-1
  #random sex indicator
  sex <- round(runif(1))
  #random age indicator
  age <- round(runif(1))
  #cleanup, show us what you got
  plain <- c(intercept,class,sex,age)
  #return full vector
  return(enc(pubKey,plain))
}

oddsList <- sapply(1:100,function(ind){
  newPassenger <- random_passenger(k$pk)
  return(plain_odds(newPassenger,encModel,k$sk,denom))
})
