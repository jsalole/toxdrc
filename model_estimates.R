#' Extract ECx model estimates and append to metadata
#'
#' This internal function uses the fitted model to extract ECx estimates (e.g., EC50),
#' and appends the result to the metadata table within a list object.
#'
#' @param dataset The dataset used to fit the model.
#' @param model A fitted `drm` model object.
#' @param metadata A one-row data.frame containing metadata to update.
#' @param EDx Numeric; the effect level to extract (default = 0.5 for EC50).
#' @param list_obj A list object being constructed across the pipeline.
#' @param ... Additional arguments passed to `ED()` (e.g., type, interval, level, lower, upper, lref, uref).
#'
#' @return Updated list_obj with ECx estimates added to `metadata`.
#' @keywords internal
#'
model_estimates <- function(dataset,
                            model,
                            metadata,
                            EDx = 0.5,
                            list_obj = NULL,
                            EDargs = list()) {
  
  manual_log_models <- c("G.2", "G.3", "G.4")
  
  
  ED_arguments <- c(list(model, c(EDx)), EDargs)
  
  # Attempt to extract ECx estimate using ...
  ED_vals <- tryCatch(
    as.vector(do.call(ED, ED_arguments)),
    error = function(e) {
      warning("ECx estimation failed in model_estimates: ", e$message)
      return(rep(NA, 4))
    }
  )
  
  # Scale to log scale if needed
  
  if (!(metadata$Model %in% manual_log_models)) {
    ED_vals <- log(ED_vals)
  } 
  
  # Define output names
  estimate_names <- c(paste0("EC", EDx * 100),
                      "Std. Error", "Lower95", "Upper95")
  
  metadata <- as.data.frame(metadata)
  metadata[estimate_names] <- NA
  
 metadata[1, estimate_names] <- ED_vals

  # Return updated list_obj
  if (is.null(list_obj)) {
    return(list(metadata = metadata))
  } else {
    list_obj$metadata <- metadata
    return(list_obj)
  }
}
