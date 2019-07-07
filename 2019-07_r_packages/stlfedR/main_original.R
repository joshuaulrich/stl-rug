# Clear environment and free up RAM
rm(list = ls())
gc()

library(DBI)
library(forecast)
library(glue)
library(lubridate)
library(RSQLite)
library(data.table)

# Some starting values
fred_id <- 'MONAN' # MO Total Non-Farm Employment
today <- Sys.Date()
start_date <- today - lubridate::years(5)
end_date <- today
freq <- 12
h <- freq

# Shady way around not asking FRED for an API key; should eventually call
# something like httr::GET() with a key, to directly return a dataframe
url <- 'https://fred.stlouisfed.org/graph/fredgraph.csv'
tmpfile <- tempfile(fileext = '.csv')
download.file(glue('{url}?id={fred_id}&cosd={start_date}&coed={end_date}'), tmpfile)

df_0 <- read.csv(tmpfile, strip.white = TRUE, stringsAsFactors = FALSE)

# Prep
df_0$DATE <- as.Date(df_0$DATE)
df_0$label <- 'Actual'

# Fit HW model
ts_0 <- ts(
    df_0[, fred_id],
    start = c(year(min(df_0$DATE)), month(min(df_0$DATE))),
    end = c(year(max(df_0$DATE)), month(max(df_0$DATE))),
    frequency = freq
)
model <- ets(ts_0, model = 'ZZZ')

# Forecast
fcast <- forecast(model, h = h)

# Get MAPE
mape <- accuracy(fcast)[5]

# Generate the date series of forecasted data
first_fcast_period <- max(df_0$DATE) + months(1)
last_fcast_period <- max(df_0$DATE) + months(h)
fcast_dates <- seq(first_fcast_period, last_fcast_period, by = 'month')

# Build output data frame
# Stub FRED_ID to replace dynamically
df_fcast <- data.frame(
    DATE = fcast_dates,
    FRED_ID = as.numeric(fcast$mean),
    label = 'Forecast',
    MAPE = mape,
    stringsAsFactors = FALSE
)

# Replace FRED_ID with actual series name
colnames(df_fcast)[which(colnames(df_fcast) == 'FRED_ID')] <- fred_id

# Build final output, and write to DB
df_out <- data.table::rbindlist(list(df_0, df_fcast), fill = TRUE)

con <- DBI::dbConnect(RSQLite::SQLite(), './fcast.db')
DBI::dbWriteTable(con, glue::glue('fcast_{fred_id}'), df_out, overwrite = TRUE)
DBI::dbDisconnect(con)

# Plot, for interactive use
plot(fcast)
