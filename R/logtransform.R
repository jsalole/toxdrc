#'Transform all concerntrations to log 10 scale.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of 'dataset' that groups observations.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#'
#' @returns A modified dataframe with an additional column, `log_Conc`.
#'
#' @export
#' @examples
#' df <- data.frame(x = rep(c(10, 100) each = 3), y = c(3, 5, 4, 20, 40, 60))
#' logtransform(dataset = df, Conc = x, Response = y)
#'
logtransform <- function(dataset, Conc, list_obj = NULL) {
  # convert Conc to numeric

  dataset <- dataset %>%
    dplyr::mutate(
      {{ Conc }} := as.numeric({{ Conc }})
    )

  # Warning if any NAs present after numeric conversion
  if (any(is.na(dplyr::pull(dataset, {{ Conc }})))) {
    warning("NA values detected in concentration column after conversion.")
  }

  # adjust 0s in Conc to ~ 0 for log transformation

  dataset <- dataset %>%
    dplyr::mutate(
      {{ Conc }} := ifelse({{ Conc }} == 0, 1e-9, {{ Conc }}),
      log_Conc = log10({{ Conc }})
    )

  # return object with log_Conc column

  if (is.null(list_obj)) {
    return(dataset)
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
