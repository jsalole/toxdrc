#' Fit multiple models and create a model comparison data frame
#'
#' This internal function fits a series of candidate models to the dataset and returns a model comparison table.
#'
#' @param dataset A data frame containing the data.
#' @param Conc Optional unquoted column name for concentration (used in standard dose-response models).
#' @param log_Conc Optional unquoted column name for log-transformed concentration (used in log-scale models).
#' @param Response Unquoted column name for the response variable (e.g., mean_response).
#' @param list_obj Optional list object to append model_df to (if NULL, a new list will be returned).
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{Unchanged dataset.}
#'   \item{model_df}{AIC-sorted model comparison data frame.}
#' }
#' @keywords internal
#'
fit_models <- function(dataset, log_Conc = NULL, Response, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("rlang", quietly = TRUE)
  requireNamespace("tibble", quietly = TRUE)
  
  # Ensure at least one concentration input is provided
  if (missing(log_Conc)) {
    stop("You must supply at least one of: Conc or log_Conc.")
  }
  
  # Start with copy of dataset and rename inputs to standard names
  ds <- dataset %>%
    dplyr::rename(Response = {{Response}})
  
  if (!missing(log_Conc)) {
    ds <- ds %>% dplyr::rename(log_Conc = {{log_Conc}})
  }
  
  model_list <- list(LL.2, LL.3u, LL.4, LL.5, LN.2, W1.2, W1.4, W2.2, W2.4, G.2, G.3, G.4)
  
  safe_model <- NULL
  fitted_model <- NULL
  
  # Fit standard models if Conc is available
  if ("log_Conc" %in% names(ds)) {
    for (model in model_list) {
      safe_model <- safe_drm(data = ds, Response ~ log_Conc, fct = model())
      if (!is.null(safe_model)) {
        fitted_model <- drm(data = ds, Response ~ log_Conc, fct = model())
        break
      }
    }
  }
  
  # Run my_mselect() if a fit was successful
  models <- if (!is.null(fitted_model)) {
    my_mselect(fitted_model, list(
      LL.2(), LL.3u(), 
      LL.4(), LL.5(), LN.2(), W1.2(), 
      W1.4(), W2.2(), W2.4(), G.2(), 
      G.3(), G.4())
      )
  } else {
    NULL
  }
  
  # Combine and clean model matrices
  model_df <- if (!is.null(models)) {
    tibble::rownames_to_column(as.data.frame(models), var = "model") %>%
      dplyr::arrange(IC)
  } else {
    NULL
  }
  
  if (!is.null(model_df) && nrow(model_df) > 0) {
    model_df <- model_df[!(model_df$model %in% c("model")), , drop = FALSE]
    model_df <- hormesis_validity(
      model_df = model_df,
      dataset = ds,
      Conc = Conc,
      Response = Response
    )
  }
  
  # Attach to list_obj
  if (is.null(list_obj)) {
    list_obj <- list(
      dataset = dataset, 
      model_df = model_df
      )
  } else {
    list_obj$model_df <- model_df
  }
  
  return(list_obj)
}

