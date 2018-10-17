#' Find total annual unit sales by platform
#'
#' @param df_in Long-format data frame of video game sales
get_annual_sales <- function(df_in) {
    df_out <- df_in %>%
        group_by(region, platform, year) %>%
        summarize(sales = sum(sales, na.rm = TRUE)) %>%
        ungroup()
    # Uncomment the following line to force validation failure
    # df_out$sales[25] <- 1000000000000000
    # validate_get_annual_sales(df_out)
    df_out
}


#' Find market share of unit sales over time
#'
#' @param df_in Long-format data frame of video game sales
get_shares <- function(df_in) {
    df_out <- df_in %>%
        group_by(region, platform, year) %>%
        summarize(sales = sum(sales, na.rm = TRUE)) %>%
        group_by(region, year) %>%
        mutate(
            mkt_share = (sales / sum(sales, na.rm = TRUE))) %>%
        ungroup()
    # Uncomment the following line to force validation failure
    # df_out$mkt_share[25] <- 1.05
    validate_get_shares(df_out)
    df_out
}


#' Clean & prepare XYZ data
#'
#' Given the XYZ data, prepares it according to your predefined business logic.
#' Note that this returns a named `list` of `data.frame`s.
#'
#' @param df_in Data frame of XYZ data
#'
#' @return A named `list` of `data.frame`s, where the element names serve as the
#'   name of each table in the target database.
#'
#' @export
prep <- function(df_in) {
    colnames(df_0) <- tolower(colnames(df_0))

    df_long <- df_0 %>%
        gather(., key = region, value = sales, contains("sales"))

    df_list <- list()

    df_list$annual_sales <- get_annual_sales(df_long)
    df_list$platform_share <- get_shares(df_long)

    df_list
}
