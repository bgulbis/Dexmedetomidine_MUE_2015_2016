# med_categories.R

#' Lookup medications by medication class
#'
#' \code{med_lookup} takes a vector of medication classes and returns all
#' medications in those classes
#'
#' This function takes a character vector of medication classes and returns a
#' data frame with all of the medications contained in the medication class. The
#' data frame will contain two columns: class_name and medication.
#'
#' @param med_class A character vector of medication classes
#'
#' @return A data frame with columns: class_name, medication
#'
#' @import dplyr
#'
#' @export
med_lookup <- function(med_class) {
    meds <- med.classes %>%

}
