#' Write out forecast data
#'
#' @param df_fcast The data frame of forecasted FRED data as returned by [forecast_FRED()]
#' @param fred_id yep
#'
#' @return Nothing
#' @export
write_sqlite <- function(df_fcast, fred_id) {
    con <- DBI::dbConnect(RSQLite::SQLite(), './fcast.db')
    DBI::dbWriteTable(con, glue::glue('fcast_{fred_id}'), df_fcast, overwrite = TRUE)
    DBI::dbDisconnect(con)
    
    print(glue::glue("Forecast data written to 'fcast.db', to table 'fcast_{fred_id}'"))
    invisible()
}
