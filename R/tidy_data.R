# tidy_data.R

#' Tidy data
#'
#' \code{tidy_data} tidy data from standard EDW queries
#'
#' This function calls the underlying tidy function based on the value passed to
#' the type parameter and returns the tidy data frame. Valid options for type
#' are: diagnosis, meds_cont, meds_outpt.
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
    } else if (type == "meds_outpt") {
        # need to pass options for class and home if included
        if ("home" %in% names(x)) {
            y <- tidy_meds_outpt(x$ref.data, x$pt.data, x$patients, x$home)
        } else {
            y <- tidy_meds_outpt(x$ref.data, x$pt.data, x$patients)
        }
    } else if (type == "meds_cont") {
        y <- tidy_meds_cont(x$ref.data, x$cont.data, x$sched.data, x$patients)
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
#' \code{tidy_meds_outpt} determines which patients have the desired outpatient
#' medications
#'
#' This function takes a data frame with reference outpatient medications or
#' medication classes and a data frame with all patient outpatient medications,
#' and returns a data frame with a logical for each medication for each patient.
#' The data frame passed to ref.data should contain two columns: name and type.
#' The name column should contain either generic medication names or medication
#' classes. The type column should specify whether the value in name is a
#' "class" or "med".
#'
#' @param ref.data A data frame with two columns, name and type
#' @param pt.data A data frame with all outpatient medications
#' @param patients A data frame with a column pie.id including all patients in
#'   study
#' @param home optional logical indicating to look for home medications if TRUE
#'   or discharge medications if FALSE
#'
#' @return A data frame
#'
#' @import dplyr
#'
tidy_meds_outpt <- function(ref.data, pt.data, patients, home = TRUE) {
    # for any med classes, lookup the meds included in the class
    meds <- filter(ref.data, type == "class")
    meds <- med_lookup(meds$name)

    # join the list of meds with any indivdual meds included
    lookup.meds <- filter(ref.data, type == "med")
    lookup.meds <- c(lookup.meds$name, meds$med.name)

    # filter to either home medications or discharge medications
    if (home == TRUE) {
        pt.data <- filter(pt.data, med.type == "Recorded / Home Meds")
    } else {
        pt.data <- filter(pt.data, med.type == "Prescription / Discharge Order")
    }

    # filter to desired meds, then spread into wide data set by med name or
    # class
    tmp <- pt.data %>%
        mutate(med = stringr::str_to_lower(med)) %>%
        filter(med %in% lookup.meds) %>%
        left_join(meds, by = c("med" = "med.name")) %>%
        mutate(group = ifelse(is.na(med.class), med, med.class),
               value = TRUE) %>%
        select(pie.id, group, value) %>%
        group_by(pie.id, group) %>%
        distinct %>%
        tidyr::spread(group, value, fill = FALSE, drop = FALSE) %>%
        full_join(select(patients, pie.id), by = "pie.id") %>%
        mutate_each(funs(ifelse(is.na(.), FALSE, .)), -pie.id)

    return(tmp)
}

#' Tidy continuous medications
#'
#' \code{tidy_meds_cont} determines which patients have the desired continuous
#' medications
#'
#' This function takes a data frame with reference medications or medication
#' classes and data frames with all continuous and scheduled medications, and
#' returns a data frame with a logical for each medication for each patient. The
#' data frame passed to ref.data should contain three columns: name, type, and
#' group. The name column should contain either generic medication names or
#' medication classes. The type column should specify whether the value in name
#' is a "class" or "med". The group column should specify whether the medication
#' is a continous or scheduled medication.
#'
#' @param ref.data A data frame with three columns: name, type, and group
#' @param cont.data A data frame with all outpatient medications
#' @param sched.data A data frame with all outpatient medications
#' @param patients A data frame with a column pie.id including all patients in
#'   study
#'
#' @return A data frame
#'
#' @import dplyr
#'
tidy_meds_cont <- function(ref.data, cont.data, sched.data, patients) {
    # tidy continuous meds
    ref.data <- filter(ref.data, group == "cont")

    # for any med classes, lookup the meds included in the class
    class.meds <- filter(ref.data, type == "class")
    class.meds <- med_lookup(class.meds$name)

    # join the list of meds with any indivdual meds included
    lookup.meds <- filter(ref.data, type == "med")
    lookup.meds <- c(lookup.meds$name, class.meds$med.name)

    # remove any rows in continuous data which are actually scheduled doses and
    # filter to desired meds
    cont.data <- anti_join(cont.data, sched.data, by = "event.id") %>%
        mutate(med = stringr::str_to_lower(med)) %>%
        filter(med %in% lookup.meds) %>%
        ungroup %>%
        group_by(pie.id, med) %>%
        arrange(med.datetime)

    return(cont.data)
}
