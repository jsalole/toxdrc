#' Comparing model fits
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of `dataset` of independent variable.
#' @param Response Unquoted column name of `dataset` of dependant variable.
#' @param model_list Optional. A list of named model function names (i.e. `model_list <- list("LL.4" = LL.4)`).
#' @param metric Dictates which model parameter is used to compare model fit.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#' @param quiet Logical. Whether results should be hidden. Default: FALSE.

#' @importFrom drc LL.4 LN.4 W1.4 W2.4
#'
#' @returns A fitetd drm model selected from the . If list_obj is provided, stores this datafram in `list_obj$model_df`.
#'
#' @export
#'
#'

# this function needs to eventually have a string2model function, where the user can input strings and the model list is generated.
modelcomp <- function(
  dataset,
  Conc,
  Response,
  model_list = NULL,
  metric = c("IC", "Res var", "Lack of fit"),
  list_obj = NULL,
  quiet = FALSE
) {
  match.arg(metric)

  # models needs a better arg name
  if (is.null(model_list)) {
    model_list <- list(
      "LL.4" = LL.4(),
      "LN.4" = LN.4(),
      "W1.4" = W1.4(),
      "W2.4" = W2.4()
    )
  }

  safe_model <- NULL
  fitted_model <- NULL
  best_model_name <- NULL
  best_model <- NULL
  model_df <- NULL

  ds <- dataset %>%
    dplyr::rename(
      Response = {{ Response }},
      Conc = {{ Conc }}
    )

  for (model in model_list) {
    safe_model <- safe_drm(data = ds, Response ~ Conc, fct = model)
    if (!is.null(safe_model)) {
      fitted_model <- drm(data = ds, Response ~ Conc, fct = model)
      # if this line is a problem, might not accept named lists. Could just unname inputted list.
      model_df <- mselect2(fitted_model, model_list, sorted = metric)
      break
    }
  }

  if (!is.null(model_df) && nrow(model_df) > 0) {
    model_df <- model_df[
      !(rownames(model_df) %in% c("model")),
      ,
      drop = FALSE
    ]

    if (!quiet) {
      print(model_df)
    }
    best_model_name <- rownames(model_df)[1]

    #if this line is the problem, add brackets directly to list entries.
    best_model <- drm(
      data = ds,
      Response ~ Conc,
      fct = model_list[[best_model_name]]
    )
    if (!quiet) {
      print(best_model)
    }
  }

  if (!is.null(list_obj)) {
    if (!is.list(list_obj)) {
      stop("Provided list_obj must be a list.")
    }
    list_obj$model_df <- model_df
    list_obj$best_model_name <- best_model_name
    list_obj$model <- best_model
    return(list_obj)
  }

  if (!quiet) {
    print(best_model)
    plot(best_model)
  }
  return(best_model)
}
