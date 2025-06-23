#' Log-transform concentration values
#'
#' This function converts concentration values to numeric, adjusts 0 concentrations to a small nonzero number (1e-9),
#' and adds a log-transformed concentration column.
#'
#' @param dataset A data frame containing the data.
#' @param Conc Unquoted column name for concentration.
#' @param list_obj Optional existing list object to update.
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{The updated dataset with numeric Conc and Log_Conc.}
#'   \item{log_concs_summary}{Summary tibble of zero values adjusted.}
#' }
#' @export
#'
log_concs <- function(dataset, Conc, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)
  
  # Convert Conc to numeric
  dataset <- dataset %>%
    dplyr::mutate(
      dplyr::across({{Conc}}, ~ as.numeric(.))
    )
  
  # Warning if any NAs present after numeric conversion
  if (any(is.na(dplyr::pull(dataset, {{Conc}})))) {
    warning("NA values detected in concentration column after conversion.")
  }
  
  # Adjust zeros and add log_Conc
  dataset <- dataset %>%
    dplyr::mutate(
      dplyr::across({{Conc}}, ~ ifelse(. == 0, 1e-9, .))
    ) %>%
    dplyr::mutate(
      log_Conc = log({{Conc}})
    )
  
  # Output
  if (is.null(list_obj)) {
    return(
      dataset = dataset,
    )
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
  