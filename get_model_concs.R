#' Tag best model and assign appropriate concentration values
#'
#' This internal helper function identifies the best model from the model_df
#' based on a given sorting criterion and assigns a new column `model_Conc`
#' using either `Conc` or `log_Conc`, depending on model type.
#'
#' @param dataset A data frame containing at least `Conc`, `log_Conc`, and response data.
#' @param model_df A model comparison data frame (e.g., from fit_models()).
#' @param sort_by Column to sort by when choosing the best model (default = "IC").
#'
#' @return A dataset with two new columns: `Model` and `model_Conc`.
#' @keywords internal
#'
get_model_concs <- function(dataset, model_df, sort_by = "IC") {
  requireNamespace("dplyr", quietly = TRUE)
  
  # Sort and get the best model name
  best_model <- model_df %>%
    dplyr::arrange(.data[[sort_by]]) %>%
    dplyr::pull(model) %>%
    .[1]
  
  # Define models that require log-transformed concentrations
  manual_log_models <- c("G.2", "G.3", "G.4")
  
  
  # Set model_Conc based on model type
  if (best_model %in% manual_log_models) {
    dataset$model_Conc <- dataset$log_Conc
  } else {
    dataset$model_Conc <- dataset$Conc
  }
  
  print(dataset)
  
  return(dataset)
}
