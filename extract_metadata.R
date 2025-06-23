#' Extracts identification columns from a dataset
#'
#' This internal function pulls selected ID columns from a row of a dataset.
#' The user can optionally provide a vector of column indices to override the defaults.
#'
#' @param dataset A data frame from which to extract metadata.
#' @param list_obj Optional existing list object to update.
#' @param ID_cols Numeric vector of column indices to extract.
#'
#' @return The updated list object with an added `metadata` field.
#' @keywords internal
#'
extract_metadata <- function(dataset, list_obj = NULL, ID_cols) {
  requireNamespace("dplyr", quietly = TRUE)
  
  # Safety check
  if (!is.data.frame(dataset) || nrow(dataset) == 0) {
    warning("Dataset is empty or not a data frame. Returning list unchanged.")
    return(list_obj)
  }
  
  # Extract one row of selected columns using tidyselect
  metadata <- dplyr::slice(dataset, 1) %>%
    dplyr::select(all_of(ID_cols))
  
  # Output
  if (is.null(list_obj)) {
    return(list(
      dataset = dataset,
      metadata = metadata
    ))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      list_obj$metadata <- metadata
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}

