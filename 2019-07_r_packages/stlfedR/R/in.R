#' Get FRED Data
#'
#' This function returns FRED data as a data frame for further analysis
#'
#' @param fred_id FRED series ID to fetch
#'
#' @return A data frame
#' @export
get_FRED <- function(fred_id) {
    # Some starting values
    today <- Sys.Date()
    start_date <- today - lubridate::years(5)
    end_date <- today
    freq <- 12
    h <- freq

    # Shady way around not asking FRED for an API key; should eventually call
    # something like httr::GET() with a key, to directly return a dataframe
    url <- 'https://fred.stlouisfed.org/graph/fredgraph.csv'
    tmpfile <- tempfile(fileext = '.csv')
    download.file(glue::glue('{url}?id={fred_id}&cosd={start_date}&coed={end_date}'), tmpfile)

    df_out <- read.csv(tmpfile, strip.white = TRUE, stringsAsFactors = FALSE)

    # Clean up a bit
    df_out$DATE <- as.Date(df_out$DATE)

    df_out
}
