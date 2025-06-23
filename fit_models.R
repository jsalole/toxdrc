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
fit_models <- function(dataset, Conc= NULL, log_Conc = NULL, Response, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("rlang", quietly = TRUE)
  requireNamespace("tibble", quietly = TRUE)

  print("infit")
  
  # Start with copy of dataset and rename inputs to standard names
  ds <- dataset %>%
    dplyr::rename(Response = {{Response}})
  
  if (!missing(log_Conc)) {
    ds <- ds %>% dplyr::rename(log_Conc = {{log_Conc}})
    ds <- ds %>% dplyr::rename(Conc = {{Conc}})
  }
  
  model_list <- list(LL.2, LL.3u, LL.4, LL.5, LN.2, W1.2, W1.4, W2.2, W2.4, BC.4, BC.5)
  log_model_list <- list (G.2, G.3, G.4)
  
  safe_model <- NULL
  log_safe_model <- NULL
  fitted_model <- NULL
  log_fitted_model <- NULL
  models <- NULL
  log_models <- NULL
  
  print("infit2")
  
  # Fit standard models if Conc is available
  if ("Conc" %in% names(ds)) {
    for (model in model_list) {
      safe_model <- safe_drm(data = ds, Response ~ Conc, fct = model())
      if (!is.null(safe_model)) {
        fitted_model <- drm(data = ds, Response ~ Conc, fct = model())
        models <- my_mselect(fitted_model, list(LL.2(), LL.3u(), 
                                                LL.4(), LL.5(), LN.2(), W1.2(), 
                                                W1.4(), W2.2(), W2.4(), BC.4(), BC.5()), sorted = "IC")
        break
      }
    }
  }
  
  print("infit3")
  
  print(models)
  
  # Fit standard models if log_Conc is available
  if ("log_Conc" %in% names(ds)) {
    for (log_model in log_model_list) {
      log_safe_model <- safe_drm(data = ds, Response ~ log_Conc, fct = log_model())
      if (!is.null(safe_model)) {
        log_fitted_model <- drm(data = ds, Response ~ log_Conc, fct = log_model())
        log_models <- my_mselect(log_fitted_model, list(G.2(), 
                                                    G.3(), G.4()))
        break
      }
    }
  }
  
  model_df <- do.call(rbind, Filter(Negate(is.null), list(log_models, models)))
  
  
  print("infit")
  print(model_df)
  
  # Combine and clean model matrices
  model_df <- if (!is.null(model_df)) {
    tibble::rownames_to_column(as.data.frame(model_df), var = "model") %>%
      dplyr::arrange(IC)
  } else {
    NULL
  }
  
  if (!is.null(model_df) && nrow(model_df) > 0) {
    model_df <- model_df[!(model_df$model %in% c("model", "log_model")), , drop = FALSE]
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

