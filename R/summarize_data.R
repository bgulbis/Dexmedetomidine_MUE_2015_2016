# summarize_data.R

#' Calculate the running time for continuous medication data
#'
#' \code{calc_runtime} calculates the time at current rate and time from
#' start
#'
#' This function takes a data frame with continuous medication rate data and
#' produces a data frame with the time at each rate and the time from start for
#' each row. This could be used to then calculate the AUC or to summarize the
#' continuous data.
#'
#' @param cont.data A data frame with continuous medication rate data
#' @param units An optional character string specifying the time units to use in
#'   calculations, default is hours
#'
#' @return A data frame
#'
#' @export
calc_runtime <- function(cont.data, units = "hours") {
    # group the data by pie.id and med
    cont.data <- dplyr::group_by_(cont.data, .dots = list("pie.id", "med"))

    # get the end of the infusion
    dots <- list(~dplyr::last(med.datetime))
    cont.end <- dplyr::summarize_(cont.data, .dots = setNames(dots, "last.datetime"))

    # add infusion end date/time to data
    cont.data <- dplyr::inner_join(cont.data, cont.end, by = c("pie.id", "med"))

    # remove all rows which are not rate documentation, unless they are the last
    # row
    dots <- list(~(med.datetime == last.datetime | !is.na(med.rate.units)))
    cont.data <- dplyr::filter_(cont.data, .dots = dots)

    # calculate the time at current rate (duration) and running time (time from
    # start)
    dots <- list(~as.numeric(difftime(dplyr::lead(med.datetime), med.datetime, units = units)),
                 ~as.numeric(difftime(med.datetime, dplyr::first(med.datetime), units = units)))

    cont.data <- dplyr::mutate_(cont.data, .dots = setNames(dots, c("duration", "run.time")))

    return(cont.data)
}

#' Summary calculations for continuous medication data
#'
#' \code{summarize_cont_meds} summarizes continuous medication data
#'
#' This function takes a data frame with continuous medication rate data and
#' produces a data frame with summary data for each patient and medication. The
#' calculations include: first rate, last rate, minimum rate, maximum rate, AUC,
#' time-weighted average rate, total infusion duration, total infusion running
#' time, and cumulative dose.
#'
#' @param cont.data A data frame with continuous medication rate data
#' @param units An optional character string specifying the time units to use in
#'   calculations, default is hours
#'
#' @return A data frame
#'
#' @export
summarize_cont_meds <- function(cont.data, units = "hours") {
    # turn off scientific notation
    options(scipen = 999)

    # get last and min non-zero rate
    nz.rate <- dplyr::filter_(cont.data, .dots = ~(med.rate > 0))
    dots <- list(~dplyr::last(med.rate), ~min(med.rate, na.rm = TRUE),
                 ~sum(duration, na.rm = TRUE))
    nm <- c("last.rate", "min.rate", "run.time")
    nz.rate <- dplyr::summarize_(nz.rate, .dots = setNames(dots, nm))

    # get first and max rates and AUC
    dots <- list(~sum(med.rate, na.rm = TRUE), ~dplyr::first(med.rate),
                 ~max(med.rate, na.rm = TRUE), ~MESS::auc(run.time, med.rate),
                 ~dplyr::last(run.time))
    nm <- c("cum.dose", "first.rate", "max.rate", "auc", "duration")
    summary.data <- dplyr::summarize_(cont.data, .dots = setNames(dots, nm))

    # join the last and min data
    summary.data <- dplyr::inner_join(summary.data, nz.rate, by = c("pie.id", "med"))

    # calculate the time-weighted average
    dots <- list(~auc/duration)
    summary.data <- dplyr::mutate_(summary.data, .dots = setNames(dots, "time.wt.avg"))

    return(summary.data)
}


#' Determine if a lab changed by a set amount within a specific time frame
#'
#' \code{lab_change} checks for changes in lab values
#'
#' This function takes a data frame with lab data for a single lab and checks
#' whether the lab changes by a certain amount within a given period of time.
#' The parameters should include: change.by, the threshold which the lab must
#' change by; FUN, the function passed to rollapplyr; back, the time frame that
#' the lab change must occur in. For FUN, use max when looking for a decrease in
#' lab value, and min when looking for an increase in lab value.
#'
#' @param lab.data A data frame with lab data
#' @param change.by A numeric indicating the threshold for lab changes
#' @param FUN A function for rollapplyr, most commonly max or min
#' @param back An optional numeric specifying the number of days back to go.
#'   Defaults to 2 days.
#'
#' @return A data frame
#'
#' @examples
#' \dontrun{
#' lab_change(data, -2, max, back = 2)
#' # checks for a >= 2 decrease in the lab value within the past 2 days
#' }
#'
#' @export
lab_change <- function(lab.data, change.by, FUN, back = 2) {
    # calculate the number of rows that are included within the window
    dots <- list(~count_rowsback(lab.datetime, back))
    lab.data <- mutate_(lab.data, .dots = setNames(dots, "rowsback"))

    # calculate the running min/max during the time window
    dots <- list(~zoo::rollapplyr(as.numeric(lab.result), rowsback, FUN,
                                  fill = NA, partial = TRUE))
    lab.data <- mutate_(lab.data, .dots = setNames(dots, "running"))

    # calcualte the change from the running min/max to current value
    dots <- list(~as.numeric(lab.result) - running)
    lab.data <- mutate_(lab.data, .dots = setNames(dots, "change"))

    # filter values which exceed the change.by value
    lab.data <- filter_(lab.data, .dots = list(~abs(change) >= abs(change.by)))

    return(lab.data)
}
