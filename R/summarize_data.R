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
#' @import dplyr
#'
#' @export
calc_runtime <- function(cont.data, units = "hours") {
    # get the end of the infusion
    cont.end <- summarize(cont.data, last.datetime = last(med.datetime))

    # calculate the time at current rate (duration) and running time (time from
    # start)
    cont.data <- cont.data %>%
        inner_join(cont.end, by = c("pie.id", "med")) %>%
        filter(med.datetime == last.datetime | !is.na(med.rate.units)) %>%
        mutate(duration = as.numeric(difftime(lead(med.datetime), med.datetime, units = units)),
               run.time = as.numeric(difftime(med.datetime, first(med.datetime), units = units)))

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
#' @import dplyr
#'
#' @export
summarize_cont_meds <- function(cont.data, units = "hours") {
    # turn off scientific notation
    options(scipen = 999)

    # get last and min non-zero rate
    nz.rate <- cont.data %>%
        filter(med.rate > 0) %>%
        summarize(last.rate = last(med.rate),
                  min.rate = min(med.rate),
                  run.time = sum(duration, na.rm = TRUE))

    # get first and max rates and AUC
    summary.data <- cont.data %>%
        summarize(cum.dose = sum(med.rate, na.rm = TRUE),
                  first.rate = first(med.rate),
                  max.rate = max(med.rate),
                  auc = MESS::auc(run.time, med.rate),
                  duration = last(run.time)) %>%
        inner_join(nz.rate, by = c("pie.id", "med")) %>%
        mutate(time.wt.avg = auc / duration)

    return(summary.data)
}
