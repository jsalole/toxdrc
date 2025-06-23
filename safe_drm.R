#' Safely fit a drm model
#'
#' This function safely fits a dose-response model using drc::drm(),
#' catching any errors and returning NULL if fitting fails.
#'
#' @param ... Arguments passed to drc::drm().
#'
#' @return A fitted drm model object, or NULL if the model fitting fails.
#' @keywords internal
#'
safe_drm <- function(...) {
  tryCatch(
    drc::drm(...),
    error = function(e) {
      message("Error in model fitting: ", e$message)
      return(NULL)  # Return NULL if model fitting fails
    }
  )
}

