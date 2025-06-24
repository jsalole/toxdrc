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
#' @param keep_cols Optional character vector of columns to preserve without averaging (any identifier columns) This will take the first non-NA value from the specified column(s) and apply to the averaged row for the column(s).
#' @param list_obj Optional existing list object to update, used in run_toxdrc(). 
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{The dataset averaged by concentration, preserving selected columns. Dataset is collapsed to 1 row per a concentration.}
#'   \item{average_response_summary}{Summary of number of concentration levels processed.}
#'   \item{pre_average_dataset}{The dataset before averaging.}
#' }
#' @export
#'
average_response <- function(dataset, Conc, Response, keep_cols = NULL, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)

  # The pre-average dataset is saved to a new name to call if needed.
  pre_average_dataset <- dataset
  
  # The specified columns are checked to see if they exist; warns user if any are not found. Moves forward with valid column names.
  if (!is.null(keep_cols)) {
    missing_cols <- keep_cols[!keep_cols %in% names(dataset)]
    if (length(missing_cols) > 0) {
      warning("Some specified keep_cols not found in dataset: ", paste(missing_cols, collapse = ", "))
      keep_cols <- keep_cols[keep_cols %in% names(dataset)]  # Only keep valid columns
    }
  }
  
  # Checking if $Note and $Validity exist in dataset; used in run_toxdrc().
  has_note <- "Note" %in% names(dataset)
  has_validity <- "Validity" %in% names(dataset)
  
  # Groups dataset by $Conc, and averages $Response. Collapses to 1 row per concentration level, and preserves first non-NA value from specified columns, $Note, and $Validity. 
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
  
  # summary shows keeps vector of unique concentration levels, if needed.
  summary_df <- tibble::tibble(
    n_conc_levels = dplyr::n_distinct(dplyr::pull(averaged_dataset, {{Conc}}))
  )
  
  # Output as a list, either a new list, or attached to supplied list_obj 
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

