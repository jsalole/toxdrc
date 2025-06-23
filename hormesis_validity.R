#' Remove hormetic models with invalid coefficients
#'
#' This function checks whether specific hormetic models (e.g., BC.4 and BC.5) show
#' implausible coefficients (e.g., negative lower asymptote or slope) and removes
#' them from the model comparison table.
#'
#' @param model_df A model comparison data frame (must include a column named `model`)
#' @param dataset A data frame containing the dose-response data
#' @param Conc Unquoted column name for concentration (default = Conc)
#' @param Response Unquoted column name for response (default = Response)
#'
#' @return A filtered model_df with invalid hormetic models removed
#' @export 
#'
hormesis_validity <- function(model_df, dataset, Conc = Conc, Response = Response) {
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("rlang", quietly = TRUE)
  
  # Standardize column names in a temporary copy
  ds <- dataset %>%
    dplyr::rename(
      Conc = {{Conc}},
      Response = {{Response}}
    )
  
  # Internal removal helper
  remove_hormetic_model <- function(df, model_name, coeff_index) {
    if (model_name %in% df$model) {
      model_fit <- safe_drm(data = ds, Response ~ Conc, fct = do.call(model_name, list()))
      if (is.null(model_fit)) {
        df <- df[df$model != model_name, , drop = FALSE]
      } else if (model_fit$coefficients[coeff_index] < 0) {
        df <- df[df$model != model_name, , drop = FALSE]
      }
    }
    return(df)
  }
  
  # Apply checks to BC models
  model_df <- remove_hormetic_model(model_df, "BC.4", 4)
  model_df <- remove_hormetic_model(model_df, "BC.5", 5)
  
  
  return(model_df)
}

