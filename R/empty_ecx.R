#' Placeholder point-estimate frame
#'
#' Returned by [getECx()] when no estimate could be produced, so that the
#'  columns match the successful path exactly.
#'
#' `check.names = FALSE` matters here: the default would rename
#'  "Effect Measure" to "Effect.Measure" and "Std. Error" to "Std..Error",
#'  giving the failure path different column names from the success path.
#'
#' Kept in its own file rather than alongside [getECx()], because a helper
#'  placed between a roxygen block and the function it documents gets bound to
#'  that block instead.
#'
#' @param EDx Numeric vector of requested effect levels.
#'
#' @returns A data frame with one row per entry in `EDx` and the columns
#'  `Effect Measure`, `Estimate`, `Std. Error`, `Lower`, and `Upper`.
#'
#' @noRd
#'
empty_ecx <- function(EDx) {
  n_ecx <- length(EDx)

  data.frame(
    "Effect Measure" = paste0("EC", EDx * 100),
    "Estimate" = rep(NA_real_, n_ecx),
    "Std. Error" = rep(NA_real_, n_ecx),
    "Lower" = rep(NA_real_, n_ecx),
    "Upper" = rep(NA_real_, n_ecx),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}
