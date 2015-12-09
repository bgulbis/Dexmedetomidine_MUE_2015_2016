# count_rowsback.R

#' Count the number of rows to go back in data frame
#'
#' \code{count_rowsback} determines how many rows should be included
#'
#' This function takes a vector of date/times (of type POSIXct) and counts the
#' number of rows which would fall within the specified time frame. Typically
#' called from \code{\link[dplyr]{mutate}} and the results are passed on to
#' \code{\link[zoo]{rollapplyr}}.
#'
#' @param datetime A vector of POSIXct values
#' @param pattern An optional numeric specifying the number of days back to go.
#'   Defaults to 2 days.
#' @return An integer with the  number of rows; can be passed on to
#'   \code{\link[zoo]{rollapplyr}}
#'
#' @export

count_rowsback <- function(datetime, back = 2) {
    sapply(datetime, function(curr.val)
        sum(ifelse(datetime >= curr.val - days(back) & datetime <= curr.val,
                   TRUE, FALSE))
    )
}
