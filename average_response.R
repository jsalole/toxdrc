#' Average response within each concentration level
#'
#' This function averages numeric columns within each concentration group,
#' carries forward specified identifier columns (using first non-NA value),
#' carries forward any flagged notes ("!") and validity flags ("*"),
#' and reduces the dataset to one row per concentration.
#'
#' @param dataset A data frame containing the data.
#' @param Conc Unquoted column name for concentration.
#' @param Response Unquoted column name for the primary response variable to calculate mean_response.
#' @param keep_cols Optional character vector of columns to preserve without averaging (e.g., identifiers like TestID, Type, etc.)
#' @param list_obj Optional existing list object to update.
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{The dataset averaged by concentration, preserving selected columns, with mean_response, Note, and Validity.}
#'   \item{average_response_summary}{Summary of number of concentration levels processed.}
#'   \item{pre_average_dataset}{The dataset before averaging.}
#' }
#' @export
#'
average_response <- function(dataset, Conc, Response, keep_cols = NULL, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)

  # Backup full dataset before any modifications
  pre_average_dataset <- dataset
  
  # Handle keep_cols safely
  if (!is.null(keep_cols)) {
    missing_cols <- keep_cols[!keep_cols %in% names(dataset)]
    if (length(missing_cols) > 0) {
      warning("Some specified keep_cols not found in dataset: ", paste(missing_cols, collapse = ", "))
      keep_cols <- keep_cols[keep_cols %in% names(dataset)]  # Only keep valid columns
    }
  }
  
  has_note <- "Note" %in% names(dataset)
  has_validity <- "Validity" %in% names(dataset)
  
  averaged_dataset <- dataset %>%
    dplyr::group_by({{Conc}}) %>%
    dplyr::summarise(
      mean_response = mean({{Response}}, na.rm = TRUE),
      dplyr::across(
        all_of(keep_cols),
        ~ dplyr::first(.),
        .names = "{.col}"
      ),
      Note = if (has_note) {
        if (any(!is.na(Note) & Note == "!")) "!" else ""
      } else {
        NA_character_
      },
      Validity = if (has_validity) {
        if (any(!is.na(Validity) & Validity == "*")) "*" else ""
      } else {
        NA_character_
      },
      .groups = "drop"
    )
  
  # Summary
  summary_df <- tibble::tibble(
    n_conc_levels = dplyr::n_distinct(dplyr::pull(averaged_dataset, {{Conc}}))
  )
  
  # Output
  if (is.null(list_obj)) {
    return(list(
      dataset = averaged_dataset,
      average_response_summary = summary_df,
      pre_average_dataset = pre_average_dataset
    ))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- averaged_dataset
      list_obj$average_response_summary <- summary_df
      list_obj$pre_average_dataset <- pre_average_dataset
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}

