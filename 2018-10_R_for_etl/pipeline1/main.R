#!/usr/bin/env Rscript

library(pipeline1)

df_0 <- read_sqlite(db = "../db.sqlite", tbl = "vgsales")

df_list <- prep(df_0)

lapply(names(df_list), function(tbl_name_i) {
    write_pg(df_list[[tbl_name_i]], tbl_name = tbl_name_i, db = "postgres", overwrite = TRUE)
})
