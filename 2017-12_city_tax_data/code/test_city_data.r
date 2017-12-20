# W. Krekeler
# 2017.12.12
#
# showcase using city data
# purposely did not use rmarkdown

# -- import code base (some may not be used; copy paste efficiency)
library(ggplot2)
library(gridExtra)
library(dplyr)
library(tidyr)
library(rjson) # fromJSON
library(RDSTK) # datascienctoolkit
library(geotools) # distKm
library(zipcode)  # zipcode database locations
library(ggmap)
library(data.table)

# make sure to vagrant up on the dstk 0.51 box!
options("RDSTK_api_base"="http://localhost:8080")  # Any localhost:8080 can be replaced by datasciencetoolkit.org if it is up


# -- paths
fileName <- list()
fileName$path <- 'C:/data/documents/docs/projects'
fileName$pathRUG <- file.path( fileName$path, 'rug_talk_20171214/code' )
fileName$fileStMap <- file.path( fileName$pathRUG, 'stMap.rds' )

# -- load local code
source( file.path( fileName$path, 'rug_talk_20171214/code/house_code_func.r' ) )

# -- define the lookup house
houseLookup <- list()
houseLookup$zipcode <- 63109
houseLookup$addressNum <- '5403'
houseLookup$addressStreet <- 'Lisette'
houseLookup$addressCity <- 'Saint Louis'
houseLookup$addressState <- 'MO'
houseLookup$purchaseYear <- 2008   # not real for given address, date to scale to though
houseLookup$purchaseMonth <- 12  # 1-12
houseLookup$purchaseDecimal <- as.integer(houseLookup$purchaseYear) + (as.integer(houseLookup$purchaseMonth)-1)/12 
houseLookup$purchasePrice <- 150000

houseLookup$addressBuilt <- paste( houseLookup$addressNum, houseLookup$addressStreet )
houseLookup$infoCoor <- street2coordinates( 
      paste( houseLookup$addressBuilt, houseLookup$addressCity, houseLookup$addressState, sep=", " ), 
      session=getCurlHandle() )


# -- get city map
stMap <- tryCatch( {
      stMap <- get_map(location=c(left=-90.3749, bottom=38.5135,right=-90.1157,top=38.7386),
                       zoom=12, scale=2, maptype="roadmap", source="google", color="bw")
      saveRDS(stMap, fileName$fileStMap)
      return(stMap)
   }, error=function(e) {
      # in case no network; 
      # no global hack but doesn't show use of finally
      return(readRDS(fileName$fileStMap))
   })

   
# -- load the city data

# - address information
fileName$CityDataPath <- file.path( fileName$path, 'data_housing/st_louis_city_data/20170701/' )
fileName$CityDataAddr <- file.path(fileName$CityDataPath, 'prcl_PrclAddr.txt')

cityData.Addr <- read.csv( fileName$CityDataAddr, header=TRUE, sep=",", stringsAsFactors=FALSE)

fileName$CityDataResInfo <- file.path(fileName$CityDataPath, 'prcl_BldgRes.txt')
cityData.ResInfo <- fread( fileName$CityDataResInfo)  # data about houses, the details

# observations:
#  everything by city block and parcel
#  many many tables which sometimes overlap
#  lots of categorical variables

# - tax information
# bulk of the data is tax data
fileName$CityDataTaxHistory <- file.path(fileName$CityDataPath, 'prcl_PrclREAR.txt')
cityData.TaxHistory <- read.csv( fileName$CityDataTaxHistory, header=TRUE, sep=",", stringsAsFactors=TRUE)  # switch to use fread instead in data.table package

# - sales information
fileName$CityDataSaleHistory1 <- file.path(fileName$CityDataPath, 'prclsale_HistPrclSale.txt')
fileName$CityDataSaleHistory2 <- file.path(fileName$CityDataPath, 'prclsale_PrclSale.txt')

cityData.Sales1 <- fread(fileName$CityDataSaleHistory1)
cityData.Sales2 <- fread(fileName$CityDataSaleHistory2)


   