# W. Krekeler
# 2017.12.11
#
# test RDSTK
# purposely did not use rmarkdown, live demo intended

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


# -- plotting the lookup house
# location =  left/bottom/right/top bound
# get range from ref: https://www.openstreetmap.org/export#map=12/38.6261/-90.2453
#        https://www.openstreetmap.org/api/0.6/map?bbox=-90.3749,38.5135,-90.1157,38.7386.
tryCatch( {
      stMap <- get_map(location=c(left=-90.3749, bottom=38.5135,right=-90.1157,top=38.7386),
                       zoom=12, scale=2, maptype="roadmap", source="google", color="bw")
      saveRDS(stMap, fileName$fileStMap)
   }, error=function(e) {
      # in case no network; XXX: warning lazy use of global modifier but it didn't like error return hacking; maybe because of finally?
      stMap <<- readRDS(fileName$fileStMap)
   }, finally={
      # print required for ggplot because inside a function
      print(ggmap( stMap ) + ggtitle("Saint Louis Road Map BW Using Name Fetch"))
   })

stMap2 <- tryCatch( {
      stMap2 <- get_map(location=c(left=-90.3749, bottom=38.5135,right=-90.1157,top=38.7386),
                       zoom=12, scale=2, maptype="roadmap", source="google", color="bw")
      saveRDS(stMap2, fileName$fileStMap)
      return(stMap2)
   }, error=function(e) {
      # in case no network; 
      # no global hack but doesn't show use of finally
      return(readRDS(fileName$fileStMap))
   })
#print(ggmap( stMap2 ) + ggtitle("Saint Louis Road Map BW Using Name Fetch"))
rm(stMap2)
   

   # zoom 12 too small (marginally), zoom 11 too big thus city is small on the map
   # ?get_openstreetmap
   #  get_openstreetmap(bbox = c(left = -90.3749, bottom = 38.5135, right =
   # -90.1157, top = 38.7386), scale = 606250, format = c("png", "jpeg",
   # "svg", "pdf", "ps"), messaging = FALSE, urlonly = FALSE,
   # filename = "ggmapTemp", color = c("color", "bw"), ...)
   # ggmap( stMap ) + ggtitle("Saint Louis Road Map BW Using Name Fetch")
   # 
   # use different package: OpenStreetMap per ref: https://help.openstreetmap.org/questions/41673/get-open-street-map-in-r
   #
   # library(OpenStreetMap) # this failed
   # install wants gdal-config which it refuses to recognize is already built and installed
   #   debug ref: https://stackoverflow.com/questions/12141422/error-gdal-config-not-found

   # above reports center url
   # as=38.62605,-90.2453&zoom=12&size=640x640&scale=1&maptype=roadmap&language=en-EN&sensor=false
ggmap(stMap) +
   geom_point( data=data.frame( longitude=houseLookup$infoCoor$longitude, latitude=houseLookup$infoCoor$latitude ),
               aes(x=longitude, y=latitude), color='red', shape=16 ) +
   ggtitle( paste('Where is ', houseLookup$addressBuilt, '\n(',
                  paste0( houseLookup$infoCoor$longitude, houseLookup$infoCoor$latitude, collapse=","),
                  ')') )


# -- other property information
# - politics: http://localhost:8080/developerdocs#coordinates2politics
houseLookup$infoPolitics <- coordinates2politics( latitude=houseLookup$infoCoor$latitude,
                                                  longitude=houseLookup$infoCoor$longitude)
print(houseLookup$infoPolitics)
   # returned as a json object; lets make it more usable in R
houseLookup$infoPolitics <- fromJSON(houseLookup$infoPolitics)

# - statistics: http://localhost:8080/developerdocs#coordinates2statistics
houseLookup$infoStats <- coordinates2statistics( latitude=houseLookup$infoCoor$latitude,
                                                 longitude=houseLookup$infoCoor$longitude)
?coordinates2statistics

houseLookup$infoStats$elevation <- coordinates2statistics( latitude=houseLookup$infoCoor$latitude,
                                                 longitude=houseLookup$infoCoor$longitude,
                                                 statistic='elevation')
for (statToGet in c('us_population_white','us_population_white_not_hispanic', 
                    'us_population_black_or_african_american','us_population_asian', 'us_population') ) {
   houseLookup$infoStats[[statToGet]] <- coordinates2statistics( latitude=houseLookup$infoCoor$latitude,
                                                           longitude=houseLookup$infoCoor$longitude,
                                                           statistic=statToGet)
}


# -- comparison distances for other properties
# cue slight of hand pre-calculated data

# - get set of zipcodes and reduce to those we care about
data(zipcode.civicspace)   # from zipcode package
zipcode.stl <- subset(zipcode.civicspace, city=='Saint Louis' & state=='MO')

# - apply to test address
houseLookup$zipcodeEst <- nearestZip( 
      houseLookup$infoCoor$latitude,
      houseLookup$infoCoor$longitude,
      zipcode.stl$latitude,
      zipcode.stl$longitude,
      zipcode.stl$zip)
print( paste('Location for ', houseLookup$addressBuilt, 
      'position = (',
         paste0( houseLookup$infoCoor$longitude, houseLookup$infoCoor$latitude, collapse=","),')',
      'Zipcode Defined:', houseLookup$zipcode,
      'Zipcode Estimate:', houseLookup$zipcodeEst ) )

# we could import zipcode shape files, plot those and confirm but not the focus of this demonstration

