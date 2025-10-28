#' Comparing model fits
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of `dataset` of independent variable.
#' @param Response Unquoted column name of `dataset` of dependant variable.
#' @param models Optional. A string of model function names (i.e. `"LL.2"`).
#' @param models_fx Optional. A list of model functions (i.e `LL.2`).
#' @param metric Dictates which model parameter is used to compare model fit.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#'
#' @importFrom drc LL.4 LN.4 W1.4 W2.4
#'
#' @returns A dataframe comparing model fits to the data. If list_obj is provided, stores this datafram in `list_obj$model_df`.
#'
#' @export
#'
#'

# this function needs to eventually have a string2model function, where the user can input strings and the model list is generated.
modelcomp <- function(
  dataset,
  Conc,
  Response,
  models = NULL,
  models_fx = NULL,
  metric = c("IC", "Res var", "Lack of fit", "no"),
  list_obj = NULL
) {
  # models needs a better arg name
  if (is.null(models)) {
    models <- (c(
      "LL.4",
      "LN.4",
      "W1.4",
      "W2.4"
    ))
  }

  if (is.null(models_fx)) {
    models_fx <- list(LL.4, LN.4, W1.4, W2.4)
  }

  safe_model <- NULL
  fitted_model <- NULL

  ds <- dataset %>%
    dplyr::rename(Response = {{ Response }})
  dplyr::rename(Conc = {{ Conc }})

  for (model in models_fx) {
    safe_model <- safe_drm(data = ds, Response ~ Conc, fct = model())
    if (!is.null(safe_model)) {
      fitted_model <- drm(data = ds, Response ~ Conc, fct = model())
      model_df <- mselect2(fitted_model, models_fx, sorted = metric)
      break
    }
  }

  if (!is.null(model_df) && nrow(model_df) > 0) {
    model_df <- model_df[
      !(model_df$model %in% c("model", "log_model")),
      ,
      drop = FALSE
    ]
    print(model_df)
  }

  if (!is.null(list_obj)) {
    if (!is.list(list_obj)) {
      stop("Provided list_obj must be a list.")
    }
    list_obj$model_df <- model_df
    return(list_obj)
  }

  return(model_df)
}
