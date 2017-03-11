#####STLRUG Analysis#####=======================================================

####Driving Distance - Google APIs####==========================================

#read in data
address_data <- read.csv("C:/stl_rug/data/rx_address.csv", 
                         stringsAsFactors = FALSE)

#create a readible address, stick columns together with '+' and replace
  #any existing spaces with a '+'
address_data$api_add <- paste(address_data$Street, address_data$City, 
                              address_data$State, sep = "+")
address_data$api_add <- gsub(" ", "+", address_data$api_add)

#get pairs of addresses
df_to_from <- data.frame(t(combn(address_data$api_add, 2)), 
                         stringsAsFactors = FALSE)

#sensible names
names(df_to_from) <- c("dest_adrs", "org_adrs")


#Set up a base url endpoint for the API
base_url <- "https://maps.googleapis.com/maps/api/distancematrix/xml?"

#stick the paramters onto this url
test_url <- paste(base_url, "origins=", df_to_from[1, 2], "&destinations=", 
                  df_to_from[1, 1], "$mode=driving", sep = "")


library(httr)    
library(XML)
#GET the web results with GET from httr and parse them with xmlParse from XML
xml_res <- xmlParse(GET(test_url))
xml_res  

#extract the durration path
xpathApply(xml_res, path = "//duration")

#we only want the first element
xpath_dur <- xpathApply(xml_res, path = "//duration")[[1]]
xpath_dur
  
#extract the actual values (in seconds) 
as.numeric(xmlValue(xmlChildren(xpath_dur)$value))

#function to return driving time and distance
get_dist_time <- function(org = "15025+Manchester+Rd+Ballwin+MO", 
                          dest = "14400+Clayton+Rd+Ballwin+MO"){
  #create url
  working_url <- paste(base_url, "origins=", org, "&destinations=", 
                       dest, sep = "")
  print(working_url)
  #return XML
  xml_res <- xmlParse(GET(working_url))
  
  #get duration (in minutes)
  xpath_dur <- xpathApply(xml_res, path = "//duration")[[1]]
  drive_time <- as.numeric(xmlValue(xmlChildren(xpath_dur)$value)) / 60
  
  #get driving distance (in miles)
  xpath_dis <- xpathApply(xml_res, path = "//distance")[[1]]
  drive_dist <- as.numeric(xmlValue(xmlChildren(xpath_dis)$value)) * 0.000621371
  
  #will be running in mapply. Need to avoid throttling limit
  Sys.sleep(0.5) 
  
  #return results
  c(drive_time, drive_dist)
}

#run this function across the entire set of to-from addresses with mapply
time_dist_res <- mapply(function(m, n)  get_dist_time(m, n), 
       m = df_to_from$dest_adrs, 
       n = df_to_from$org_adrs, 
       SIMPLIFY = TRUE)

time_dist_res <- mapply(get_dist_time, 
                        dest =  df_to_from$dest_adrs, 
                        org = df_to_from$org_adrs, 
                        SIMPLIFY = TRUE)


#stick the results onto the initial df_to_from data frame
complete_results <- cbind(df_to_from, 
                          data.frame(t(time_dist_res), row.names = NULL))

#rename
names(complete_results)[3:4] <- c("drive_time", "drive_distance")


#Geocoding API

#get a new base url for the geocoding API
gc_base_url <- "http://maps.google.com/maps/api/geocode/xml?address="

#use one of our addresses to test the API
test_gc_url <- paste(gc_base_url, complete_results$dest_adrs[1], sep = "")

#pull back the XML
test_gc_xml_res <- xmlParse(GET(gc_test_url))

#extract the nodes for the latitude and longitude
test_lat <- as.numeric(xmlValue(xmlChildren(xpathApply(gc_xml_res, path = "//location/lat")[[1]])[[1]]))
test_lon <- as.numeric(xmlValue(xmlChildren(xpathApply(gc_xml_res, path = "//location/lng")[[1]])[[1]]))

#function to pull back lat / lon
find_ll <- function(adrs){
  gc_url <- paste(gc_base_url, adrs, sep = "")
  print(gc_url)
  gc_xml <- xmlParse(GET(gc_url))
  lat <- as.numeric(xmlValue(xmlChildren(xpathApply(gc_xml, 
                                                    path = "//location/lat")[[1]])[[1]]))
  lon <- as.numeric(xmlValue(xmlChildren(xpathApply(gc_xml, 
                                                    path = "//location/lng")[[1]])[[1]]))
  Sys.sleep(0.5) 
  c(lat, lon)
}

#get all lat / lon for unique addresses
unq_adrs <- unique(complete_results$dest_adrs)
all_lat_lon <- sapply(unq_adrs, function(m) find_ll(m))

geo_coded_results <- data.frame(unq_adrs, t(all_lat_lon), row.names = NULL, 
                                stringsAsFactors = FALSE)

names(geo_coded_results)[2:3] <- c("lat", "lon")


#google places API

#base url

places_base_url <- "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="

#test coord
test_cord <- paste(geo_coded_results$lat[1], 
                   geo_coded_results$lon[1], sep = ",")  

#test url
places_test_url <- paste(places_base_url, test_cord, 
                  "&radius=10000&type=pharmacy,&keyword=walmart&key=", api_key, 
                  sep = "")

#get json data and pull in the results
library(RJSONIO)
json_full <- fromJSON(places_test_url)
json_res <- json_full$results

#get the interesting parts of the results
#lat-long
ll <- lapply(json_res, function(m) m$geometry$location)
#names 
nme <- lapply(json_res, function(m) m$name)
#vicinity (address)
vins <- lapply(json_res, function(m) m$vicinity)

#stick all of these results together
ll_df <- data.frame(do.call("rbind", ll), 
                    stringsAsFactors = FALSE)

nme_df <- data.frame(do.call("rbind", nme), 
                    stringsAsFactors = FALSE)

vins_df <- data.frame(do.call("rbind", vins), 
                     stringsAsFactors = FALSE)

#combine and de-dupe
library(tidyverse)
place_res <- data.frame(nme_df, vins_df, ll_df, stringsAsFactors = FALSE) %>%
  distinct()

#get sensible results for pharmacies only
names(place_res) <- c("loc_name", "loc_adrs", "lat", "lng")
place_res <- place_res %>%
  filter(grepl("pharmacy", tolower(loc_name))) %>%
  mutate(clean_add = gsub("[^[:alnum:]]+", "+", loc_adrs))

#Then run each of these addresses through the finding address function
gsub("[^[:alnum:]]+", "+", place_res$loc_adrs)

drive_dist_hold <- rep(NA, times = nrow(place_res))

for (i in 1: nrow(place_res)){
  drive_dist_hold[i] <- get_dist_time(geo_coded_results$unq_adrs[1], 
                                   paste(place_res$lat[i], 
                                         place_res$lng[i], sep = ","))[2]
}

#Find min
closest_walmart <- place_res[which.min(drive_dist_hold), ]



####Sunshine Act / Large Data####===============================================

#create a path for the zip file we download
unz_dest <- "C:/stl_rug/data/sunshine_act_13.ZIP"

#provide R with the url from which we want to download the data
sa_13_url <- "http://download.cms.gov/openpayments/PGYR13_P063016.ZIP"

#download the file from the provided URL to the provided destination folder
  #we use the mode = "wb" argument because it is a zip file
download.file(sa_13_url, unz_dest, mode = "wb")
#Unzip the file to a folder called sunshine_act_13_files
unzip(unz_dest, exdir = "C:/stl_rug/data/sunshine_act_13_files")

#set up paths to read in the general and resarch payments
path_gen_13 <- paste("C:/stl_rug/data/sunshine_act_13_files/", 
                     "OP_DTL_GNRL_PGYR2013_P06302016.csv", sep = "")
path_res_13 <- paste("C:/stl_rug/data/sunshine_act_13_files/", 
                     "OP_DTL_RSRCH_PGYR2013_P06302016.csv", sep = "")

library(readr)
system.time(read.csv(path_res_13))
system.time(read_csv(path_res_13))

system.time(read.csv(path_gen_13))
system.time(read_csv(path_gen_13))

res_13 <- read_csv(path_res_13)
gen_13 <- read_csv(path_gen_13)

#get row and column count
dim(res_13)
dim(gen_13)

#figure out types and first few observations
str(res_13)
str(gen_13)

#get tables of missing values
missing_vals_gen <- data.frame(colMeans(is.na(gen_13)))
missing_vals_res<- data.frame(colMeans(is.na(res_13)))

library(tidyverse)
#Select only interesting fields from the general data
gen_small <- gen_13 %>%
  select(Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name, 
         Date_of_Payment, Nature_of_Payment_or_Transfer_of_Value, 
         Physician_Last_Name, Physician_First_Name, Physician_Profile_ID,
         Recipient_State, 
         Total_Amount_of_Payment_USDollars, 
         Recipient_Zip_Code) %>%
  rename(MFG = Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,
         Payment_Nature = Nature_of_Payment_or_Transfer_of_Value,
         Phys_Last = Physician_Last_Name, 
         Phys_First = Physician_First_Name, 
         State = Recipient_State,
         Pmt_Total = Total_Amount_of_Payment_USDollars, 
         Zip_code = Recipient_Zip_Code)

#Select 
res_small <- res_13 %>%
  select(Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name, 
         Date_of_Payment, Principal_Investigator_1_Last_Name, 
         Principal_Investigator_1_First_Name, 
         Principal_Investigator_1_Profile_ID,
         Principal_Investigator_1_State,
         Total_Amount_of_Payment_USDollars,
         Principal_Investigator_1_Zip_Code) %>%
  rename(MFG = Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,
         Phys_Last = Principal_Investigator_1_Last_Name, 
         Phys_First = Principal_Investigator_1_First_Name, 
         State = Principal_Investigator_1_State,
         Pmt_Total = Total_Amount_of_Payment_USDollars,
         Zip_code = Principal_Investigator_1_Zip_Code)

#Get the top 10 manufacturers by spend in research payments
res_summary <- res_small %>%
  group_by(MFG) %>% #Row headers in our pivot table
  summarise(total_payment_val = sum(Pmt_Total), #sum of all payments
            avg_payment = mean(Pmt_Total), #average payment value
            number_of_records = n()) %>% #get a count of records
  top_n(n = 10, wt = total_payment_val) #top 10 by total payment

#Get the top 10 manufacturers by spend in general payments
gen_summary <- gen_small %>%
  group_by(MFG) %>% #Row headers in our pivot table
  summarise(total_payment_val = sum(Pmt_Total), #sum of all payments
            avg_payment = mean(Pmt_Total), #average payment value
            number_of_records = n()) %>% #get a count of records
  top_n(n = 10, wt = total_payment_val) #top 10 by total payment

library(lubridate)
#Find the general payments by month
gen_mo_sum <- gen_small %>%
  mutate(mo_start = floor_date(mdy(Date_of_Payment), "month")) %>% #add month start column
  group_by(mo_start) %>%
  summarise(total_payment_val = sum(Pmt_Total))

#Find the number of unique manufacturers making general payments by state
gen_mfg_state_sum <- gen_small %>%
  group_by(State) %>%
  mutate(mfgs_making_pmts = length(unique(MFG))) %>%
  select(State, mfgs_making_pmts) %>%
  ungroup() %>%
  distinct() %>%
  arrange(desc(mfgs_making_pmts))

#find the total spend by mfg on research payments in missouri and illinois
mo_il_res <- res_small %>%
  filter(State %in% c("MO", "IL")) %>%
  group_by(MFG) %>%
  summarise(tot_payment_val = sum(Pmt_Total))

#pull out the mfg info from the general payments
gen_mfg_only <- gen_small %>%
  select(MFG, Pmt_Total) %>%
  mutate(Type = "General")

#pull out the mfg info from the research payments
res_mfg_only <- res_small %>%
  select(MFG, Pmt_Total) %>%
  mutate(Type = "Research")

#stick these two together
comb_data <- bind_rows(gen_mfg_only, res_mfg_only)

#aggregate by type and mfg
comb_data_agg <- comb_data %>%
  group_by(MFG, Type) %>%
  summarise(tot_payment_val = sum(Pmt_Total))

#turn the type column into two new columns
wide_comb_data <- comb_data_agg %>%
  spread(key = Type, value = tot_payment_val, fill = 0)

library(scales)
ggplot(data = wide_comb_data, aes(x = Research, y = General)) +
  geom_point() + geom_text(data = subset(wide_comb_data, Research > 40000000 | 
                                           General > 15000000), 
                           aes(label = MFG), size = 3) +
  scale_x_continuous(name = "Research Payments", 
                     label = dollar) +
  scale_y_continuous(name = "General Payments", 
                     label = dollar) +
  ggtitle("2013 Sunshine Act Data - Relationship Between General and Research Payments", 
          subtitle = paste("Only MFGs with over $15M in General Payments or $40M",  
                           " in Reserach Payments are labeled", sep = ""))
  
#general payments by nature
library(stringr)
gen_small %>%
  mutate(ntr_warp = str_wrap(Payment_Nature, width = 40)) %>%
  group_by(ntr_warp) %>%
  summarise(tot_payment_val = sum(Pmt_Total), 
            number_of_payments = n()) %>%
  ggplot(aes(x = ntr_warp, y = tot_payment_val, 
             fill = number_of_payments)) + 
  geom_bar(stat = "identity") +
  scale_y_continuous(name = "2013 General Payment Value", 
                     label = dollar) +
  scale_x_discrete(name = "Nature of Payment") +
  scale_fill_continuous(name = "Number of Payments") +
  ggtitle("2013 General Payments - Breakdown by Payment Nature") +
  theme(axis.text.x = element_text(angle = 90))

#geography of MO and IL payments
#pull out the mfg info from the general payments
mo_il_gen <- gen_small %>%
  filter(State %in% c("MO", "IL")) %>%
  select(MFG, Pmt_Total, Zip_code) %>%
  mutate(Type = "General")

#pull out the mfg info from the research payments
mo_il_res <- res_small %>%
  filter(State %in% c("MO", "IL")) %>%
  select(MFG, Pmt_Total,  Zip_code) %>%
  mutate(Type = "Research")

#stick these two together
mo_il_comb_data <- bind_rows(mo_il_gen, mo_il_res)

#aggregate by type, zipcode, and mfg
mo_il_comb_data_agg <- mo_il_comb_data %>%
  group_by(MFG, Type, Zip_code) %>%
  summarise(tot_payment_val = sum(Pmt_Total))

library(zipcode)

#clean zipcode and add lat / lon
mo_il_comb_data_agg <- mo_il_comb_data_agg %>%
  mutate(zip = clean.zipcodes(Zip_code)) %>% 
  left_join(zipcode) %>%
  filter(state %in% c("IL", "MO"))

state_data <- map_data("state") %>%
  filter(region %in% c("missouri", "illinois"))

ggplot() + geom_polygon(data = state_data, aes(x = long, y = lat, 
                                               group = group), 
                        colour="grey50",fill="grey90") +
  geom_point(data = mo_il_comb_data_agg, 
             aes(x = longitude, y = latitude, colour = Type, 
                 size = tot_payment_val)) +
  scale_size_continuous(name = "Total Payment Value", 
                        label = dollar) + 
  scale_colour_manual(values = c("#00B050", "#0B79BF")) +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank()) +
  coord_map() +
  ggtitle("2013 Open Payment Data - Research and General Payment Totals Aggregated by Zip Code")

  
  

