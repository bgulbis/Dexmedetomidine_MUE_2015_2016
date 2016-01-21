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
#' @import dplyr
#'
#' @export
med_lookup <- function(med_class) {
    meds <- med.classes %>%
        filter(med.class %in% med_class)

    return(meds)
}

#' Lookup medication class by medication generic name
#'
#' \code{med_class_lookup} takes a vector of medication generic names and returns the
#' classes which contain those medications
#'
#' This function takes a character vector of medication generic names and returns a data
#' frame with all of the medication classes that contain those medications. The
#' data frame will contain two columns: med.class and med.name.
#'
#' @param meds A character vector of medication names
#'
#' @return A data frame with columns: med.class and med.name
#'
#' @import dplyr
#'
#' @export
med_class_lookup <- function(meds) {
    lookup <- paste(meds, collapse = "|")

    meds <- med.classes %>%
        mutate(contains = stringr::str_detect(med.name, stringr::regex(lookup, ignore_case = TRUE))) %>%
        filter(contains == TRUE) %>%
        select(-contains)

    return(meds)
}
