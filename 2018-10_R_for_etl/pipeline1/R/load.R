#' Write to a PostgreSQL database connection
#'
#' Given a database `db` and a table `tbl`, returns a `data.frame`.
#'
#' @param df_out Data frame to write as a DB table.
#' @param tbl_name Resultant table name in target database, passed as a string.
#' @param db Database name, passed as a string.
#' @param ... Other args passed on to [DBI::dbWriteTable()].
#'
#' @export
write_pg <- function(df_out, tbl_name, db, ...) {
    con <- dbConnect(RPostgres::Postgres(),
                     dbname = db,
                     host = "127.0.0.1",
                     port = 5432,
                     user = "postgres",
                     password = "postgres")
    dbWriteTable(con, name = tbl_name, value = df_out, ...)
    dbDisconnect(con)
}
