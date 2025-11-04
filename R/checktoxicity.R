#' Check for toxic effect
#'
#' This test can be used to scan datasets to determine if toxicity has occured. Useful to filter out tests prior to modelling steps.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of `dataset` that groups observations (e.g. Conc).
#' @param Response Unquoted column name of `dataset` with observations (e.g. RFU).
#' @param effect Numeric value dictating the point at which observations are flagged as toxic; can be relative or absolute (see `type`.)
#' @param type Indicates if the effect argument is relative ("rel") to `reference group` or an absolute value ("abs").
#' @param reference_group Quoted name OR value of reference group to compare response to (i.e. "ctl", 0)
#' @param target_group Optional. Can be used to limit the compairison to certain groups (highest exposure concentration).
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#'
#' @returns The supplied dataset, unchanged, with and a printed message indicating if a test is or is not toxic. If list_obj is supplied, the results of the test  are saved under `effect`, where `effect = TRUE` indicates an effect that exceeds the threshold.
#' @export
#'
#' @examples
#' df <- data.frame(x = rep(1:2, each = 3), y = c(100, 110, 90, 40, 50, 60))
#' lt <- list(dataset = df, Group = "B")
#' checktoxicity(dataset = lt$dataset, Conc = x, Response = y, effect = 85,
#' type = "abs", list_obj = lt)
#'
checktoxicity <- function(
  dataset,
  Conc,
  Response,
  effect,
  type = c("rel", "abs"),
  reference_group = "0",
  target_group = NULL,
  list_obj = NULL
) {
  type <- match.arg(type)

  # establish threshold for both relative and absolute

  .data <- NULL # to avoid error from NSE in pull

  if (type == "rel") {
    response_threshold <- dataset %>%
      dplyr::filter({{ Conc }} == reference_group) %>%
      dplyr::summarise(
        threshold = mean({{ Response }}, na.rm = TRUE) * effect
      ) %>%
      dplyr::pull(.data$threshold)
  } else {
    response_threshold <- effect
  }

  # filter dataset if applicable

  if (!is.null(target_group)) {
    summary_df <- dataset %>%
      dplyr::filter({{ Conc }}) ==
      target_group
  } else {
    summary_df <- dataset
  }

  # check if response above threshold

  response_values <- dplyr::pull(summary_df, {{ Response }})
  all_above <- all(response_values > response_threshold)
  if (all_above == TRUE) {
    print("Test effect does not exceed threshold")
    toxic_effect <- FALSE
  } else {
    print("Test effect exceeds threshold")
    toxic_effect <- TRUE
  }

  # store results

  if (is.null(list_obj)) {
    return(toxic_effect)
  }

  if (is.list(list_obj)) {
    list_obj$dataset <- dataset
    list_obj$effect <- toxic_effect
    return(list_obj)
  } else {
    stop("Provided list_obj must be a list.")
  }
}
