# code purely for loading the data
# data from the uci machine learning repository
# https://archive.ics.uci.edu/ml/datasets/online+retail
library(gdata)
df = read.xls(
  "C:/Users/Alexander/Documents/talks/assoc/retail.xlsx", 
  sheet = 1, 
  header = TRUE,
  perl = "C:/Strawberry/perl/bin/perl.exe"
)
save.image("C:/Users/Alexander/Documents/talks/assoc/retail")

#code for doing the actual computations
library(arules)

load("C:/Users/Alexander/Documents/talks/assoc/retail")

# a thick dataset with 4210 columns if represented via counts on items
length(unique(df$StockCode))

#somewhat nonstandard use of aggregate
formatted <- aggregate(
  df[c('Description')],
  by=df[c('InvoiceNo')],
  unique
)
# formatted$Description will be a list of 
# atomic vectors with no repeated elements

#compute rules 
rules <- apriori(
  formatted$Description,
  parameter = list (
    supp = 0.005, 
    conf = 0.9, 
    maxlen=3)
)

# restrictive parameters => few rules 
length(rules)
#rules have their own class
class(rules)
# the apriori function actually coerced our data 
# to a a type called a transaction
class(as(formatted$Description,'transactions'))

#statistical properties the rules
summary(rules)

#what happens when we choose different parameters?
rulesBig <- apriori(
  formatted$Description,
  parameter = list (
    supp = 0.005, 
    conf = 0.5, 
    maxlen=4)
)
#we now have many more rules than before, 3727 from 114
length(rulesBig)

#visualizations
library(arulesViz)

#the birds eye view
plot(rules)

#filter down to the high support rules
inspect(head(sort(rules, by = "support"),10))

#make a web graph of the high support rules
plot(
  head(sort(rules, by = "support"), 10), 
  method="graph", 
  control=list(type="items")
)




as(rules, "data.frame")

#redo everything with shorter tags to make a full web
formattedLite <- aggregate(
  df[c('StockCode')],
  by=df[c('InvoiceNo')],
  unique
)
# formatted$Description will be a list of 
# atomic vectors with no repeated elements

#compute rules 
rulesLite <- apriori(
  formattedLite$StockCode,
  parameter = list (
    supp = 0.005, 
    conf = 0.9, 
    maxlen=3)
)
#make a web graph of the high support rules
plot(
  rulesLite, 
  method="graph", 
  control=list(type="items")
)

