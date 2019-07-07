#!/usr/bin/env Rscript

library(stlfedR)

fred_id <- 'MONAN'
freq <- 12
h <- 12

df_0 <- get_FRED(fred_id)

df_fcast <- forecast_FRED(df_0, fred_id, freq = freq, h = h)

write_sqlite(df_fcast, fred_id)
