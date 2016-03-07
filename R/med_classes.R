# med_classes.R

#' Lookup medications by medication class
#'
#' \code{med_lookup} takes a vector of medication classes and returns all
#' medications in those classes
#'
#' This function takes a character vector of medication classes and returns a
#' data frame with all of the medications (by generic name) contained in the
#' medication class. The data frame will contain two columns: med.class and
#' med.name.
#'
#' Medication class data comes from the Enterprise Data Warehouse.
#'
#' @param med_class A character vector of medication classes
#'
#' @return A data frame with columns: med.class and med.name
#'
#' @export
med_lookup <- function(med_class) {
    # filter med.classes to only the desired classes
    dots <- list(~med.class %in% med_class)
    meds <- dplyr::filter_(med.classes, .dots = dots)

    return(meds)
}

#' Lookup medication class by medication generic name
#'
#' \code{med_class_lookup} takes a vector of medication generic names and
#' returns the classes which contain those medications
#'
#' This function takes a character vector of medication generic names and
#' returns a data frame with all of the medication classes that contain those
#' medications. The data frame will contain two columns: med.class and med.name.
#'
#' @param meds A character vector of medication names
#'
#' @return A data frame with columns: med.class and med.name
#'
#' @export
med_class_lookup <- function(meds) {
    # make a regular expression string of desired meds
    lookup <- paste(meds, collapse = "|")

    # check each medication to see if it is in the list of desired meds
    regex <- stringr::regex(lookup, ignore_case = TRUE)
    dots <- list(~stringr::str_detect(med.name, regex))
    meds <- dplyr::mutate_(med.classes, .dots = setNames(dots, "contains"))

    # filter only medications which match
    meds <- dplyr::filter_(meds, .dots = list(~contains == TRUE))

    # remove contains from data frame
    meds <- dplyr::select_(meds, .dots = list(quote(-contains)))

    return(meds)
}
