#' Pull first non missing or blank value
#'
#' @param x Input vector.
#'
#' @noRd
#'
#'
first_nonmissing <- function(x) {
  if (is.factor(x)) {
    x <- as.character(x)
  }
  x <- x[!is.na(x) & x != ""]
  if (length(x) == 0) NA_character_ else x[1]
}
