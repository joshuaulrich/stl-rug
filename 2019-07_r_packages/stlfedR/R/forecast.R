#' Generate forecast of FRED data
#'
#' Title duh
#'
#' @param df_in A data frame with FRED data
#' @param fred_id yep
#' @param freq yep
#' @param h yep
#'
#' @return A data.frame
#' @export
forecast_FRED <- function(df_in, fred_id, freq, h) {
    # Add initial series label flag
    df_in$label <- 'Actual'

    # Fit HW model
    ts_0 <- ts(
        df_in[, fred_id],
        start = c(year(min(df_in$DATE)), month(min(df_in$DATE))),
        end = c(year(max(df_in$DATE)), month(max(df_in$DATE))),
        frequency = freq
    )
    model <- ets(ts_0, model = 'ZZZ')

    # Forecast
    fcast <- forecast(model, h = h)

    # Get MAPE
    mape <- accuracy(fcast)[5]

    # Generate the date series of forecasted data
    first_fcast_period <- max(df_in$DATE) + months(1)
    last_fcast_period <- max(df_in$DATE) + months(h)
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
    df_out <- data.table::rbindlist(list(df_in, df_fcast), fill = TRUE)

    df_out
}
