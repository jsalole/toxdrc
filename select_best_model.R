#' Select and fit the best model from model_df
#'
#' This function selects the top-ranked model from the model_df (sorted by IC),
#' fits it using model_Conc and Response, and returns the fitted model
#' along with metadata.
#'
#' @param dataset A data frame with `model_Conc` and response column (e.g., Viability or mean_response).
#' @param model_df A model comparison data frame with a column `model`.
#' @param Response Unquoted column name for response variable.
#' @param Conc Column to use for x (default = model_Conc).
#' @param list_obj Optional list object to append model_name and drm_model to.
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{Unchanged dataset.}
#'   \item{best_model}{Name of the best model.}
#'   \item{drm_model}{The fitted model object.}
#' }
#' @export 
#'
select_best_model <- function(dataset, model_df, Response, Conc = log_Conc, list_obj = NULL) {
  requireNamespace("drc", quietly = TRUE)
  requireNamespace("rlang", quietly = TRUE)
  requireNamespace("dplyr", quietly = TRUE)
  
  # Rename to standard columns
  ds <- dataset %>%
    dplyr::rename(
      Response = {{Response}},
      mConc = {{Conc}}
    )
  
  # Get best model name
  best_model_name <- model_df %>%
    dplyr::arrange(IC) %>%
    dplyr::pull(model) %>%
    .[1]
  
  # Model function mapping
  model_functions <- list(
    "BC.4" = BC.4(), "BC.5" = BC.5(), "LL.2" = LL.2(), "LL.3u" = LL.3u(),
    "LL.4" = LL.4(), "LL.5" = LL.5(), "LN.2" = LN.2(), "W1.2" = W1.2(),
    "W1.4" = W1.4(), "W2.2" = W2.2(), "W2.4" = W2.4(), "G.2" = G.2(),
    "G.3" = G.3(), "G.4" = G.4()
  )
  
  # Fit model
  dr_model <- tryCatch({
    drm(Response ~ mConc, data = ds, fct = model_functions[[best_model_name]])
  }, error = function(e) {
    warning(paste("Model fitting failed for", best_model_name, ":", e$message))
    return(NULL)
  })
  
  # Return as list
  if (is.null(list_obj)) {
    return(list(
      dataset = dataset,
      best_model = best_model_name,
      dr_model = dr_model
    ))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      list_obj$dataset$Model <- best_model_name
      list_obj$best_model <- best_model_name
      list_obj$dr_model <- dr_model
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}

