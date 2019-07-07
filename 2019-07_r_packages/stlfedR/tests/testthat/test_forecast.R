context('Forecast functions')

test_that('fcast_FRED() works', {
    # Some defaults
    fred_id <- 'MONAN'
    freq <- 12
    h <- 12
    df_0  <- get_FRED(fred_id)
    df_fcast <- forecast_FRED(df_0, fred_id, freq = freq, h = h)

    expect_equal(nrow(df_fcast), nrow(df_0) + h)
    expect_equal(colnames(df_fcast), c('DATE', fred_id, 'label', 'MAPE'))

    # Change h
    df_fcast <- forecast_FRED(df_0, fred_id, freq = freq, h = 6)

    expect_equal(nrow(df_fcast), nrow(df_0) + 6)
})
