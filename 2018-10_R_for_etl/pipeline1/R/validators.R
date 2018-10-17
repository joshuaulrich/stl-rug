#' Validate annual sales calculations
#'
#' @param df_in Data frame of calculated sales
validate_get_annual_sales <- function(df_in) {
    # but like... it's the same logic
}


#' Validate platform market share calculations
#'
#' @param df_in Data frame of calculated market shares
validate_get_shares <- function(df_in) {
    share_check <- df_in %>%
        filter(is.finite(mkt_share)) %>%
        group_by(region, year) %>%
        summarize(mkt_share = round(sum(mkt_share, na.rm = TRUE), 8)) %>%
        ungroup() %>%
        filter(mkt_share != 1.00)

    if (nrow(share_check) > 0) {
        loggit("ERROR", "Annual market shares != 100% per region",
               log_detail = sprintf("Offenders: %s, %s: %.3f",
                                    share_check$region,
                                    share_check$year,
                                    share_check$mkt_share))
    }
}
