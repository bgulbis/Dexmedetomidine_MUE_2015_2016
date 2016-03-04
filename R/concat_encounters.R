# concat_encounters.R

#' Make concatenated list of encounters
#'
#' \code{concat_encounters} takes a vector of encounters and produces a
#' concatenated list for use in EDW
#'
#' This function takes a vector of encounters and concatenates them together,
#' separated by a semi-colon. The list is then split into the desired group
#' size. The resulting string can be used in an EDW query prompt.#'
#'
#' @param encounters A character vector with the encounters
#' @param num.split An optional numeric indicating the number to split on,
#'   default is 1000
#'
#' @return A list
#'
#' @export
concat_encounters <- function(encounters, num.split = 1000) {
    # split the vector into groups
    edw.pie <- split(encounters, ceiling(seq_along(encounters) / num.split))
    # make a string of encounters, separated by a semi-colon
    edw.pie <- lapply(edw.pie, stringr::str_c, collapse = ";")

    return(edw.pie)
}
