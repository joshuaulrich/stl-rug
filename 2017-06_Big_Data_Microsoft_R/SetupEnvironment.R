
# local R_Server lib<- 'C:\\Program Files \\Microsoft\\R Server \\R_SERVER\\library'
# SQLServer
#lib <- "C:\\Program Files\\Microsoft SQL Server\\MSSQL13.MSSQLSERVER\\R_SERVICES\\library"
#.libPaths(c(.libPaths(), lib))


#####################################################################
# Check for latest and greatest packages
#####################################################################
#update.packages(ask = FALSE)

#####################################################################
# Set up the Environment
# loading CRAN R packages 
#####################################################################

#options("repos" = c(CRAN = "http://cran.r-project.org/"))
#install.packages('stringr')
#install.packages('dplyr')
#install.packages('lubridate')
#install.packages('rgeos') # spatial package
#install.packages('sp') # spatial package
#install.packages('maptools') # spatial package
#install.packages('ggmap')
#install.packages('ggplot2')
#install.packages('gridExtra') # for putting plots side by side
#install.packages('ggrepel') # avoid text overlap in plots
#install.packages('tidyr')
#install.packages('seriation') # package for reordering a distance matrix

#####################################################################
# loading Markdown packages
#####################################################################
options("repos" = c(CRAN = "http://cran.r-project.org/"))

#install.packages("knitr")
#install.packages("rmarkdown")
#install.packages("colorspace")
library("knitr")
library("rmarkdown")
library("colorspace")
library("htmltools")
library("yaml")


#####################################################################
# Set up the Environment
# loading RevoScale R packages 
#####################################################################

options(max.print = 1000, scipen = 999, width = 90)
library(RevoScaleR)
rxOptions(reportProgress = 1) # reduces the amount of output RevoScaleR produces
library(dplyr)
options(dplyr.print_max = 2000)
options(dplyr.width = Inf) # shows all columns of a tbl_df object
library(stringr)
library(lubridate)
library(rgeos) # spatial package
library(sp) # spatial package
library(maptools) # spatial package
library(ggmap)
library(ggplot2)
library(gridExtra) # for putting plots side by side
library(ggrepel) # avoid text overlap in plots
library(tidyr)
#library(seriation) # package for reordering a distance matrix

#setwd('C:\\Users\\trobinson\\Documents\\Presentations\\Analyzing Big Data with Microsoft R')
getwd()
rm(list=ls())
ls()