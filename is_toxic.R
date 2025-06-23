#' Check if toxicity is present before model fitting
#'
#' This function checks whether all concentrations show viability (or normalized response) above a specified threshold.
#' If all means are above the threshold, the sample is considered non-toxic and model fitting can be skipped.
#'
#' @param dataset A data frame containing the data.
#' @param Conc Unquoted column name for concentration.
#' @param Response Unquoted column name for viability or normalized response.
#' @param effect_level Numeric value; threshold above which data is considered non-toxic (default = 0.7).
#' @param list_obj Optional existing list object to update.
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{Unchanged dataset.}
#'   \item{is_toxic}{TRUE if toxicity is present (mean values fall below threshold), FALSE otherwise.}
#' }
#' @export
#'
is_toxic <- function(dataset, Conc, Response, effect_level = 0.7, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)
  
  # Step 1: Calculate threshold from Conc == 0
  response_threshold <- dataset %>%
    dplyr::filter({{ Conc }} == 0) %>%
    dplyr::summarise(threshold = mean({{ Response }}, na.rm = TRUE) * effect_level) %>%
    dplyr::pull(threshold)
  
  # Step 2: Check if all means are above the threshold
  all_above_threshold <- dataset %>%
    dplyr::group_by({{ Conc }}) %>%
    dplyr::summarise(mean_response = mean({{ Response }}, na.rm = TRUE), .groups = "drop") %>%
    dplyr::summarise(all_above = all(mean_response > response_threshold)) %>%
    dplyr::pull(all_above)
  
  # Step 3: Determine toxicity flag
  if (is.na(all_above_threshold)) {
    warning("Toxicity check resulted in NA. Response data may be missing.")
    is_toxic <- NA
  } else {
    is_toxic <- !all_above_threshold  # TRUE = toxicity detected
  }
  
  # Output
  if (is.null(list_obj)) {
    return(list(
      dataset = dataset,
      is_toxic = is_toxic
    ))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      list_obj$is_toxic <- is_toxic
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}

