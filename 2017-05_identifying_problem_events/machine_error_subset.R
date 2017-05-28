library(dplyr)
library(data.table)
library(xts)
library(stringr)
library(scales)
library(shiny)
library(ggplot2)
library(DT)
library(reshape2)
library(plotly)
library(devtools)

# Data <- data.frame(DT_ID=integer(),
#                      EQMT_NO=integer(),
#                      RUN_DT=character(),
#                      RUN_SHIFT=integer(),
#                      BEGIN_TIME=character(),
#                      PLCSYSTEM_ID=character(),
#                      DURATION=integer(),
#                      EVENT_NO=integer(),
#                      DURATION_NOP=integer(),
#                      EMPLOYEE_NO=character(),
#                      DURATION_ADJ=integer(),
#                      BRWY=character(),
#                      Line_Number=integer(),
#                      Fault_Code=character(),
#                      stringsAsFactors=FALSE
# )
# 
# months <- c('Apr','Aug','Dec','Feb','Jan','July','Mar','June','May','Nov','Oct','Sept')
# years <- c('2015','2016')
# 
# file_string <- c()
# base <- "~/Daugherty/Analytics/AB POC/Faults_"
# end <- "_Simple.xlsx"
# for(year in years) {
#   for(month in months){
#     file_string <- c(file_string, paste(base,month, year, end, sep = '', collapse=''))
#   }
# }
# 
# for(month_string in file_string) {
#   if(file.exists(month_string)) Data <- rbind(read_excel(month_string), Data)
# }
#
# Data$RUN_DT <- as.Date(Data$RUN_DT, format = "%m/%d/%Y")
# Data$BEGIN_TIME <- as.POSIXct(Data$BEGIN_TIME, format = "%m/%d/%Y %I:%M:%S %p")
# Data <- Data[order(Data$BEGIN_TIME),]

# setwd("C:/Users/Owner/Desktop/615810/thats/Documents/Ryan/R Projects/Error Code Probability/WebApp/FindSequences")
# load("C:/Users/Owner/Desktop/615810/thats/Documents/Ryan/R Projects/Error Code Probability/data.Rda")

Data <- read.csv("C:/Users/Owner/Desktop/615810/thats/Documents/Ryan/R Projects/Error Code Probability/DISTRIBUTION.csv")
Data <- data.frame(Data)

Data$BRWYLine <- paste(Data$BRWY, Data$Line_Number, sep = "/")
# Write frequency matrix.
#setwd("~/Ryan/R Projects/Error Code Probability")
#write.csv(freqTop, file="freq.csv")

########################
# Fault Code frequency #
########################
faultCodeFrequency <- function(FuncData, line) {
  FuncData <- as.data.frame(FuncData[which(FuncData[, 15] == line),])
  # Calculate frequency of fault codes by brewery line.
  freq <- as.data.frame(ungroup(mutate(summarise(group_by(FuncData, BRWYLine,Fault_Code), n = n()), freq = n / sum(n))))
  # Format frequency to 4 decimal points.
  freq$freq <- round(freq$freq,4)
  # Put the top 5 fault code frequencies by brewery line in a data table.
  freqTop <- data.table(freq)[order(freq, decreasing = TRUE), head(.SD, 5), by="BRWYLine"]
  # Remove column n from data table.
  freqTop$n <- NULL
  # Swing freqTop table into a crosstab. Brewery Line columns, Fault Code rows.  The sum function sums each combination of BrwyLine/FaultCode in the data table.
  freqTop <- tapply(freqTop$freq,list(freqTop$Fault_Code, freqTop$BRWYLine), FUN=sum)
  # Calculate sum of frequencies.
  freqTopSum <- as.matrix(t(colSums(freqTop,na.rm=TRUE)))
  # Name sum row.
  rownames(freqTopSum) <- ('Total')
  # Add sum row to frequency matrix.
  freqTopCount <- rbind(freqTop, freqTopSum)
  freqTopCount <- na.omit(freqTopCount)
  result <- freqTopCount
  result
}

#############################################
# Fault Code total percent unched down time #
#############################################
faultCodePctTotalTime <- function(FuncData, line) {
  FuncData <- as.data.frame(FuncData[which(FuncData[, 15] == line),])
  # Calculate percent of unscheduled downtime by brewery line.
  freq <- as.data.frame(ungroup(mutate(summarise(group_by(FuncData, BRWYLine,Fault_Code), n = sum(DURATION,na.rm=T)), freq = n / sum(n))))
  # Format frequency to 4 decimal points.
  freq$freq <- round(freq$freq,4)
  # Put the top 5 fault code frequencies by brewery line in a data table.
  freqTop <- data.table(freq)[order(freq, decreasing = TRUE), head(.SD, 5), by="BRWYLine"]
  # Remove column n from data table.
  freqTop$n <- NULL
  # Swing freqTop table into a crosstab. Brewery Line columns, Fault Code rows.  The sum function sums each combination of BrwyLine/FaultCode in the data table.
  freqTop <- tapply(freqTop$freq,list(freqTop$Fault_Code, freqTop$BRWYLine), FUN=sum)
  # Calculate sum of frequencies.
  freqTopSum <- as.matrix(t(colSums(freqTop,na.rm=TRUE)))
  # Name sum row.
  rownames(freqTopSum) <- ('Total')
  # Add sum row to frequency matrix.
  freqPctDowntime <- rbind(freqTop, freqTopSum)
  freqPctDowntime <- na.omit(freqPctDowntime)
  result <- freqPctDowntime
  result
}

#####################################
# Fault Code total unched down time #
#####################################
faultCodeTotalTime <- function(FuncData, line) {
  FuncData <- as.data.frame(FuncData[which(FuncData[, 15] == line),])
  # Convert unscheduled downtime to hours.
  FuncData$DURATION <- FuncData$DURATION/60/60
  # Calculate average unscheduled downtime by brewery line.
  agg_tot <- as.data.frame(summarize(group_by(FuncData, BRWYLine,Fault_Code),tot = sum(DURATION,na.rm=T)))
  # Format average to no decimal points.
  agg_tot$tot <- round(agg_tot$tot,2)
  # Put the top 5 fault code averages by brewery line in a data table.
  totTop <- data.table(agg_tot)[order(tot, decreasing = TRUE), head(.SD, 5), by="BRWYLine"]
  # Swing avgTop table into a crosstab. Brewery Line columns, Fault Code rows.  The sum function sums each combination of BrwyLine/FaultCode in the data table.
  totTop <- tapply(totTop$tot,list(totTop$Fault_Code, totTop$BRWYLine), FUN=sum)
  # Calculate sum of frequencies.
  freqTotSum <- as.matrix(t(colSums(totTop,na.rm=TRUE)))
  # Name sum row.
  rownames(freqTotSum) <- ('Total')
  # Add sum row to frequency matrix.
  freqTopDowntime <- rbind(totTop, freqTotSum)
  freqTopDowntime <- na.omit(freqTopDowntime)
  result <- freqTopDowntime
  result
}

####################################
# Fault Code mean unched down time #
####################################
faultCodeAverageTime <- function(FuncData, line) {
  FuncData <- as.data.frame(FuncData[which(FuncData[, 15] == line),])
  # Convert unscheduled downtime to hours.
  FuncData$DURATION <- FuncData$DURATION/60/60
  # Calculate average unscheduled downtime by brewery line.
  agg_avg <- as.data.frame(summarize(group_by(FuncData, BRWYLine,Fault_Code),avg = mean(DURATION,na.rm=T)))
  # Format average to no decimal points.
  agg_avg$avg <- round(agg_avg$avg,2)
  # Put the top 5 fault code averages by brewery line in a data table.
  avgTop <- data.table(agg_avg)[order(avg, decreasing = TRUE), head(.SD, 5), by="BRWYLine"]
  # Swing avgTop table into a crosstab. Brewery Line columns, Fault Code rows.  The sum function sums each combination of BrwyLine/FaultCode in the data table.
  avgTop <- tapply(avgTop$avg,list(avgTop$Fault_Code, avgTop$BRWYLine), FUN=sum)
  avgTop <- na.omit(avgTop)
  result <- avgTop
  result
}

######################################
# Fault Code median unched down time #
######################################
faultCodeMedianTime <- function(FuncData, line) {
  FuncData <- as.data.frame(FuncData[which(FuncData[, 15] == line),])
  # Convert unscheduled downtime to hours.
  FuncData$DURATION <- FuncData$DURATION/60/60
  # Calculate median unscheduled downtime by brewery line.
  agg_med <- as.data.frame(summarize(group_by(FuncData, BRWYLine,Fault_Code),med = median(DURATION,na.rm=T)))
  # Format median to no decimal points.
  agg_med$med <- round(agg_med$med,2)
  # Put the top 5 fault code medians by brewery line in a data table.
  medTop <- data.table(agg_med)[order(med, decreasing = TRUE), head(.SD, 5), by="BRWYLine"]
  # Swing medTop table into a crosstab. Brewery Line columns, Fault Code rows.  The sum function sums each combination of BrwyLine/FaultCode in the data table.
  medTop <- tapply(medTop$med,list(medTop$Fault_Code, medTop$BRWYLine), FUN=sum)
  medTop <- na.omit(medTop)
  result <- medTop
  result
}

faultCodeSequences <- function(FuncData, code, line, depth) {
  FuncData <- as.data.frame(FuncData[which(FuncData[, 15] == line),])
  seq <- FuncData[which(FuncData[, 14] == code) - 1, 14]
  if (depth > 1) {
    depth <- 2:depth
    for(d in depth) {
      seq <- paste(FuncData[pmax(which(FuncData[, 14] == code) - d,0), 14],seq, sep = "-")
    }
  }
  result <- seq
  result
}

faultCodeProbabilities <- function(FuncData, code, seq, depth) {
  FuncStats <- data.frame(n=integer(),prob=numeric())
  seq <- strsplit(seq, "-")
  c <- ncol(FuncData) + 1
  for (i in 1:depth) {
    FuncData <- FuncData[which(FuncData[, (c - i)] == seq[[1]][i]), ]
  }
  N <- length(FuncData$Fault_Code)
  FuncData <- FuncData[which(FuncData[, 14] == code), ]
  FuncStats[1,1] <- length(FuncData$Fault_Code)
  FuncStats$prob <-  round(FuncStats$n/N,4)
  result <- FuncStats
  result
}