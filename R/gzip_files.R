# gzip_files.R

#' Compress data files
#'
#' \code{gzip_files} compresses all data files in a directory using gzip, if not
#' already compressed
#'
#' This function takes the name of a directory and checks all of the data files
#' within the directory to if they are already compressed. For each file that is
#' not, it will compress the file using \code{\link[R.utils]{gzip}}.
#'
#' @param dir.name A string with the name of the directory containing the data
#'   files. Defaults to the current working directory.
#'
#' @seealso \code{\link[R.utils]{gzip}}
#'
#' @export
gzip_files <- function(dir.name = getwd()) {
    comp.files <- list.files(dir.name, full.names=TRUE)
    lapply(comp.files, function(x) if (R.utils::isGzipped(x) == FALSE) R.utils::gzip(x))
}
