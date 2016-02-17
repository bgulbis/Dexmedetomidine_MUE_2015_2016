# tidy_data.R

#' Tidy data
#'
#' \code{tidy_data} tidy data from standard EDW queries
#'
#' This function calls the underlying tidy function based on the value passed to
#' the type parameter and returns the tidy data frame. Valid options for type
#' are: diagnosis, outpt_meds.
#'
#' @param type A character indicating what type of data is being tidied
#' @param ... parameters to pass on to the underlying tidy function
#'
#' @return A data frame
#'
#' @import dplyr
#'
#' @export
tidy_data <- function(type, ...) {
    # get list of parameters from ellipsis
    x <- list(...)

    # call the desired tidy function based on type
    if (type == "diagnosis") {
        y <- tidy_diagnosis(x$ref.data, x$pt.data, x$patients)
    } else if (type == "outpt_meds") {
        # need to pass options for class and home if included
        y <- tidy_outpt_meds(x$ref.data, x$pt.data, x$patients)
    } else {
        y <- "Invalid type"
    }

    return(y)
}

#' Tidy diagnosis codes
#'
#' \code{tidy_diagnosis} determines which patients have the desired diagnosis
#'
#' This function takes a data frame with reference diagnosis codes and a data
#' frame with all patient diagnosis codes, and returns a data frame with a
#' logical for each disease state for each patient.
#'
#' @param ref.data A data frame with the desired diagnosis codes
#' @param pt.data A data frame with all patient diagnosis codes
#' @param patients A data frame with a column pie.id including all patients in study
#'
#' @return A data frame
#'
#' @import dplyr
#'
tidy_diagnosis <- function(ref.data, pt.data, patients) {
    # convert any CCS codes to ICD9
    lookup.codes <- icd9_lookup(ref.data) %>%
        ungroup %>%
        mutate(disease.state = factor(disease.state))

    tmp <- pt.data %>%
        filter(diag.type != "Admitting",
               diag.type != "Working") %>%
        inner_join(lookup.codes, by = c("diag.code" = "icd9.code")) %>%
        mutate(value = TRUE) %>%
        select(pie.id, disease.state, value) %>%
        group_by(pie.id, disease.state) %>%
        distinct %>%
        tidyr::spread(disease.state, value, fill = FALSE, drop = FALSE) %>%
        full_join(select(patients, pie.id), by = "pie.id") %>%
        mutate_each(funs(ifelse(is.na(.), FALSE, .)), -pie.id)

    return(tmp)
}

#' Tidy outpatient medications
#'
#' \code{tidy_outpt_meds} determines which patients have the desired outpatient
#' medications
#'
#' This function takes a data frame with reference outpatient medications and a
#' data frame with all patient outpatient medications, and returns a data frame
#' with a logical for each medication for each patient.
#'
#' @param ref.data A data frame with the desired diagnosis codes
#' @param pt.data A data frame with all patient diagnosis codes
#' @param patients A data frame with a column pie.id including all patients in
#'   study
#' @param class optional logical indicating whether medications should be
#'   grouped by class, default is TRUE
#' @param home optional logical indicating to look for home medications if TRUE
#'   or discharge medications if FALSE
#'
#' @return A data frame
#'
#' @import dplyr
#'
tidy_outpt_meds <- function(ref.data, pt.data, patients, class = TRUE, home = TRUE) {
    # if class is TRUE, group by medication class
    if (class == TRUE) {
        ref.data <- ref.data %>%
            ungroup %>%
            mutate(med.class = factor(med.class))
    }

    # filter to either home medications or discharge medications
    if (home == TRUE) {
        pt.data <- filter(pt.data, med.type == "Recorded / Home Meds")
    } else {
        pt.data <- filter(pt.data, med.type == "Prescription / Discharge Order")
    }

    tmp <- pt.data %>%
        mutate(med = stringr::str_to_lower(med)) %>%
        inner_join(ref.data, by = c("med" = "med.name")) %>%
        mutate(value = TRUE) %>%
        select(pie.id, med.class, value) %>%
        group_by(pie.id, med.class) %>%
        distinct %>%
        tidyr::spread(med.class, value, fill = FALSE, drop = FALSE) %>%
        full_join(select(patients, pie.id), by = "pie.id") %>%
        mutate_each(funs(ifelse(is.na(.), FALSE, .)), -pie.id)

    return(tmp)
}
