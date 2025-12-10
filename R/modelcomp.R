#' Compare model fits and select best model
#'
#' @description
#' Data is fitted to provided models, typically from the drc package. Models
#'  fitted successfully are compared using multiple goodness-of-fit scores,
#'  and organized using the score given as the `metric` argument.
#'  arguement.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param model_list List. Model functions to be tested. Defaults to
#'  include `"LL.4"`, `"LN.4"`, `"W1.4"`, `"W2.4"`. Most models from the drc
#'  package are compatible; use `drc::getMeanFunctions()` for a more options.
#'  See details for formatting
#' @param metric Character. Criterion used to select the best
#'  model. Choices are `"IC"`, `"Res var"`, `"Lack of fit"`. Defaults
#'  to "IC".
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.

#' @importFrom drc LL.4 LN.4 W1.4 W2.4
#'
#' @returns A fitted drm model. If `list_obj` is provided, returns this within
#' the list as `list_obj$best_model`, along with the model name
#'  (`list_obj$best_model_name`), and the model compairison dataframe
#'  (`list_obj$model_df`). If model fitting fails, returns NULL.
#'
#' @examples
#' toxresult2 <- toxresult[!toxresult$Conc %in% c ("Control", "Blank"),]
#' toxresult2$Conc <- as.numeric(toxresult2$Conc)
#' modelcomp(toxresult2, Conc, RFU, metric = "IC")
#'
#' @seealso [drc::getMeanFunctions()] for compatabile models and their
#'  shorthand for `model_list`.
#'
#' @details
#' The `model_list` argument requires a specific style. The argument must be a
#'  list; entries in the list are in the format where the shorthand is the name of
#'  the model function. An example of this is `"LL.4" = LL.4()`.
#'
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
