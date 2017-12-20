# general relevant functions
# I didn't go back and test everything I pulled out;
# some functions may not work as they were test functions;
# 
#

library(geotools) # distKm

#` return latitude, longitude coordinates for passed address
#` uses RDSTK function street2coordinates,
#`
#` @PARAM ADDRESS = number and street name
#` @PARAM CITY = city
#` @PARAM STATE = abbreviation, or name of state
#` @RETURN latitude and longitude coordinates or NULL if fails
#`
getStreetCoordinates <- function( ADDRESS, CITY = 'Saint Louis', STATE = 'MO') {
   # must handle if not valid to return 'something'
   tryCatch( {
         return( street2coordinates( paste( ADDRESS, CITY, STATE, sep=", " ), session=getCurlHandle() ) )
      #}, warning = function(w) {
      #     return(NULL) 
      }, error = function(e) {
            print(paste0('Return null for not found: ', e, ' at address: ', ADDRESS ))
            return(NULL)
      }
   )
}


#` return boolean if invalidate data in X by length or NULL
#` PARAM X = value to pass in
#` RETURN = TRUE if valid, FALSE if invalid data
#`
whichIsValid <- function( X ) {
   if (length(X) == 0) {
      return(FALSE)
   }
   if (is.null(X) ) {   # | is.na(X) causes error: argument is of length zero because of null elements
      return(FALSE)
   } else {
      if (class(X) == "list") {
         if ( is.null(X[[1]]) ) {
            return(FALSE)
         } else {
            return(TRUE)
         }
      } else {
         return(TRUE)   
      }
      
   }
}


#` for a given latitude and longitude return a zipcode estimate, 
#` return the closest zipcode to latitude and logitude in the set given
#`   the l*Sets and zipcodes must be the same size
#`
#` @PARAM latitude = size 1
#` @PARAM longitude = size 1
#` @PARAM latitudeSet, from zipcode library, linked to zipcodes
#` @PARAM longitudeSet, from zipcode library, linked to zipcodes
#` @PARAM zipcodes, from zipcode library
#`    must be the same size as latitudeSet and longitudeSet
#` @RETURN closest zipcode to given lat, long position
#`
#` example call: nearestZip(latitude,longitude, zipcode.stl$latitude, zipcode.stl$longitude, zipcode.stl$zip)

nearestZip <- function (latitude, longitude, latitudeSet, longitudeSet, zipcodes) {
   
   if ( (length(latitudeSet) != length(longitudeSet))
      || (length(latitudeSet) != length(zipcodes)) ) {
      # the passed sets must be the same size or the algorithm will fail
      return( -1 );
   }
   if ( ((length(latitude) != 1) && (length(latitude) != length(latitudeSet)))
      || ((length(longitude) != 1) && (length(longitude) != length(latitudeSet))) ) {
      # one or both can be the same size as the sets passed
      # but can not be a non-one size that does not match passed set length
      return(-1)
   }
   if ( length(latitudeSet) == 0 ) {
      # because everything is checked against above, 
      # only need to check one value to determine all are 0 size
      return(0);
   }
   
   # distKm(lat0,lon0,lat1,lon1)
   #   distKm(latitude,longitude, zipcode.stl$latitude, zipcode.stl$longitude)
   distances <- distKm(latitude, longitude, latitudeSet, longitudeSet)
   
   return( zipcodes[which( rank( distances, na.last = TRUE, ties.method = "min" ) == 1 )] )
        
}

getCoordinateStatisticsCallStatList <- function( X, STATISTIC_LIST ) {
      # must pass X as LATITUDE and LONGITUDE in that order
      #return( getCoordinateStatistics(STATISTIC, X[1], X[2] ) )
      tryCatch( {
            # compute statisticsByCoor
            return( do.call( rbind.data.frame, lapply(STATISTIC_LIST, getCoordinateStatistics, X[1], X[2]) ) )
         }, error = function(e) {
               print(paste0('GCSCSL: Return null for not found: ', e, ' at ( ', X[1], ", ", X[2], ")." ))
               return(NULL)
         }
      )
   }
   getCoordinateStatisticsCall <- function( X, STATISTIC ) {
      # must pass X as LATITUDE, LONGITUDE in that order as string
      #return( getCoordinateStatistics(STATISTIC, X[1], X[2] ) )
      tryCatch( {
            # compute statisticsByCoor
            #latlong <- unlist( strsplit(X,sep=",") )
            print ( paste(STATISTIC, X[1], X[2], sep=" -- ") )
            return( getCoordinateStatistics(STATISTIC, X[1], X[2]) )
         }, error = function(e) {
               print(paste0('GCSC: Return null for not found: ', e, ' at ( ', X[1], ", ", X[2], ")." ))
            return(NULL)
         }
      )
   }
   getCoordinateStatistics <- function( STATISTIC, LATITUDE, LONGITUDE ) {
      # must handle if not valid to return 'something'
      tryCatch( {
            return( coordinates2statistics(LATITUDE, LONGITUDE, STATISTIC, session=getCurlHandle()) )
         }, error = function(e) {
               #print(paste0('GCS: Return null for not found: ', e, ' at ( ', LATITUDE, ", ", LONGITUDE, ") for: ", STATISTIC,"." ))
               return(NULL)
         }
      )
   }
   valueNonly <- function( X, N) {
      # return only N value(s) from a list
      return( X[N])
   }
   