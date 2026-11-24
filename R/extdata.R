#' Path to a bundled example PDF
#'
#' @param file Base name of a file under `inst/extdata`; omit to list
#'   the available files.
#' @return A file path (if `file` is given) or a character vector of
#'   available file names (if it is omitted).
#' @examples
#' bst260_example()
#' bst260_example("2021_Annual_Waterborne_Disease_Surveillance_Report.pdf")
#' @export
bst260_example <- function(file = NULL) {
  if (is.null(file)) return(list.files(system.file("extdata", package = "bst260projhelp")))
  path <- system.file("extdata", file, package = "bst260projhelp")
  if (!nzchar(path)) stop("no such file: ", file, ". See bst260_example() for available files.")
  path
}
