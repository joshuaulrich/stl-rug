#' Read from the example SQLite database connection
#'
#' Given a SQLite database path `db` and a table `tbl`, returns a `data.frame`.
#'
#' @param db SQLite database path name, passed as a string.
#' @param tbl Table name, passed as a string.
#'
#' @export
read_sqlite <- function(db, tbl) {
    con <- dbConnect(RSQLite::SQLite(), dbname = db)
    df_out <- dbReadTable(con, tbl)
    dbDisconnect(con)
    df_out
}
