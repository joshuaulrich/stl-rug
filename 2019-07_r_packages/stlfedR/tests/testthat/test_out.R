context('Data output functions')

test_that('write_sqlite() works', {
    # Some defaults
    fred_id <- 'MONAN'
    freq <- 12
    h <- 12
    df_0  <- get_FRED(fred_id = fred_id)
    df_fcast <- forecast_FRED(df_0, fred_id, freq = freq, h = h)
    write_sqlite(df_fcast, fred_id = fred_id)

    expect_true(file.exists('./fcast.db'))

    # Read back in from SQLite for checking
    con <- DBI::dbConnect(RSQLite::SQLite(), './fcast.db')
    dbtable <- DBI::dbReadTable(con, glue::glue('fcast_{fred_id}'))
    DBI::dbDisconnect(con)

    # Need to adjust some coltypes on read-in, because of SQLite's representation
    dbtable$DATE <- as.Date(dbtable$DATE, origin = '1970-01-01')

    expect_equivalent(as.data.frame(df_fcast), as.data.frame(dbtable))
})
