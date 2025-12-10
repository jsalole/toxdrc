#' Wrapped drm in tryCatch.
#'
#' @noRd
#'
#' @importFrom drc drm
#'
safe_drm <- function(formula, data, fct) {
  tryCatch(
    drm(formula, data = data, fct = fct),
    error = function(e) NULL
  )
}
