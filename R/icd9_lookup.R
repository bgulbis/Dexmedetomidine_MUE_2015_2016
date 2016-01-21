# icd9_lookup.R

#' Lookup ICD9 codes from CCS codes
#'
#' \code{icd9_lookup} takes a data frame with CCS codes and returns the
#' corresponding ICD9 codes
#'
#' This function takes a data frame with three columns: disease.state, type, and
#' code. The column \code{disease.state} is a character field with the name of a
#' disease state which will be used for grouping. The column \code{type} is a
#' character field with either "ICD9" or "CCS", which indicates the type of
#' code. The column \code{code} is a character field with the ICD9 or CCS code.
#' For all rows with CCS codes, the function will look-up the corresponding ICD9
#' code and then return a data frame with two columns: disease.state and
#' icd9.code. The procedure parameter is used to specify whether diagnosis codes
#' or procedure codes should be returned.
#'
#'
#' @param df A data frame with columns: disease.state, type, code
#' @param procedure A logical indicating whether to use diagnosis codes
#'   (default) or procedure codes
#'
#' @return A data frame with columns: disease.state, icd9.code
#'
#' @import dplyr
#'
#' @export
icd9_lookup <- function(df, procedure = FALSE) {
    if (procedure == TRUE) {
        data <- ccs.procedures
    } else {
        data <- ccs.diagnosis
    }

    # find the ICD9 codes for the desired exclusions by CCS code
    ccs <- filter(df, type == "CCS") %>%
        mutate(ccs.code = as.numeric(code)) %>%
        inner_join(data, by="ccs.code")

    # ICD9 codes for non-CCS code exclusions
    icd9 <- filter(df, type=="ICD9") %>%
        mutate(icd9.code = code) %>%
        inner_join(data, by="icd9.code")

    # create one table with all ICD9 codes that should be excluded
    codes <- bind_rows(ccs, icd9) %>%
        select(disease.state, icd9.code) %>%
        group_by(disease.state)

    return(codes)
}


#' Lookup ICD9 code description
#'
#' \code{icd9_description} takes a vector of ICD9 codes and returns a data frame
#' with the corresponding description for each code
#'
#' This function takes a character vector of ICD9 codes and returns a data frame
#' with two columns: icd9.code and icd9.description.
#'
#'
#' @param codes A character vector of ICD9 codes
#' @param procedure A logical indicating whether to use diagnosis codes
#'   (default) or procedure codes
#'
#' @return A data frame with columns: icd9.code and icd9.description
#'
#' @import dplyr
#'
#' @export
icd9_description <- function(codes, procedure = FALSE) {
    if (procedure == TRUE) {
        data <- ccs.procedures
    } else {
        data <- ccs.diagnosis
    }

    descript <- data %>%
        filter(icd9.code %in% codes) %>%
        select(icd9.code, icd9.description)

    return(descript)
}
