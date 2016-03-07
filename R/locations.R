# locations.R

#' Calculate the length of stay in each unit
#'
#' \code{calc_unit_los} calculates the length of stay in each hospital unit
#'
#' This function takes a data frame with arrival and departure times and
#' determines the length of stay in each unit. This accounts for data which
#' might contain duplicate arrival or departure information.
#'
#' @param unit.data A data frame with hospital unit arrival and departure
#'   information
#' @param units An optional character string specifying the time units to use in
#'   calculations, default is days
#'
#' @return A data frame
#'
#' @export
calc_unit_los <- function(unit.data, units = "days") {
    # turn off scientific notation
    options(scipen = 999)

    # group the data by patient and sort by arrival date/time
    unit.data <- dplyr::group_by_(unit.data, "pie.id")
    unit.data <- dplyr::arrange_(unit.data, "arrive.datetime")

    # check if the patient actually moved to a new unit; assign each unique unit
    # a number to be used for grouping
    dots <- list(~ifelse(is.na(unit.to) | is.na(dplyr::lag(unit.to)) |
                             unit.to != dplyr::lag(unit.to), TRUE, FALSE),
                 ~cumsum(diff.unit))
    nm <- list("diff.unit", "unit.count")
    unit.data <- dplyr::mutate_(unit.data, .dots = setNames(dots, nm))

    # regroup the data by patient and unit
    unit.data <- dplyr::ungroup(unit.data)
    unit.data <- dplyr::group_by_(unit.data, .dots = list("pie.id",
                                                          "unit.count"))

    # find the first time a patient arrived in a unit, or last time they left
    dots <- list(~dplyr::first(unit.to), ~dplyr::first(arrive.datetime),
                  ~dplyr::last(depart.datetime))
    nm <- list("unit.to", "arrive.datetime", "depart.datetime")
    unit.data <- dplyr::summarize_(unit.data, .dots = setNames(dots, nm))

    # calculate the length of stay in each unit
    dots <- list(~dplyr::lead(arrive.datetime),
                 ~ifelse(is.na(calc.depart.datetime),
                         difftime(depart.datetime, arrive.datetime,
                                  units = units),
                         difftime(calc.depart.datetime, arrive.datetime,
                                  units = units)))
    nm <- list("calc.depart.datetime", "unit.los")
    unit.data <- dplyr::mutate_(unit.data, .dots = setNames(dots, nm))

    unit.data <- dplyr::ungroup(unit.data)

    return(unit.data)
}
