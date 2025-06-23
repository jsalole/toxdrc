#' Add placeholder ECx metadata on failure
#'
#' This internal function adds NA-filled ECx estimate columns to the metadata when model fitting fails.
#'
#' @param metadata A one-row data.frame of metadata for the current test.
#' @param list_obj A list object to which the updated metadata should be attached.
#' @param EDx Numeric value indicating which ECx to initialize (default = 0.5 for EC50).
#'
#' @return A list_obj with updated `metadata` containing placeholder ECx columns.
#' @keywords internal
#'
red_button <- function(metadata, EDx = 0.5) {
  ed_label <- paste0("EC", EDx * 100)
  cols_to_add <- c(ed_label, "Std. Error", "Lower95", "Upper95")
  
  metadata <- as.data.frame(metadata)
  for (col in cols_to_add) {
    metadata[[col]] <- NA
  }
  
    return(metadata)
}
