# filter_data.R

#' Filter values to specified date range
#'
#' \code{filter_dates} filters data to within a specified time frame
#'
#' This function takes a data frame with a column called \code{datetime} and a
#' data frame with columns called \code{start.datetime} and \code{end.datetime},
#' and filters the data to only include values within the specified time frame.
#' Optionally, two additional parameters (prior.start and after.end) can be
#' included to add additional time before or after the start or end date and
#' time. Both data frames should include a pie.id column to use for joining.
#'
#' @param data A data frame with a date/time column called datetime
#' @param criteria A data frame with start and stop date/time columns called
#'   start.datetime and end.datetime
#' @param prior.start An optional numeric indicating number of days to go back
#'   prior to the start date/time, default is 0
#' @param after.end An optional numeric indicating number of days after the end
#'   date/time to include, default is 0
#' @param dtcols An optional vector of strings with the names of the columns to
#'   be used for filtering
#'
#' @return A data frame
#'
#' @export
filter_dates <- function(data, criteria, prior.start = 0, after.end = 0,
                         dtcols = c("datetime", "start.datetime",
                                    "stop.datetime")) {
    # drop any additional columns from criteria
    dots <- list("pie.id", lazyeval::interp(quote(x), x = as.name(dtcols[2])),
                 lazyeval::interp(quote(y), y = as.name(dtcols[3])))
    criteria <- select_(criteria, .dots = dots)

    # join data and criteria
    dates <- inner_join(data, criteria, by = "pie.id")

    # include data from the specified number of days prior to start date/time
    # forward
    dots <- list(lazyeval::interp(~x >= y - days(z), x = as.name(dtcols[1]),
                                  y = as.name(dtcols[2]), z = prior.start))
    dates <- filter_(dates, .dots = dots)

    # include data up to the specified number of days after the stop date/time
    dots <- list(lazyeval::interp(~x <= y + days(z), x = as.name(dtcols[1]),
                                  y = as.name(dtcols[3]), z = after.end))
    dates <- filter_(dates, .dots = dots)

    # remove start and stop columns
    dots <- list(lazyeval::interp(quote(-x), x = as.name(dtcols[2])),
                 lazyeval::interp(quote(-y), y = as.name(dtcols[3])))
    dates <- select_(dates, .dots = dots)

    return(dates)
}

