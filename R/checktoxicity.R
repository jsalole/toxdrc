#' Check for an effect
#'
#' @description
#' `checktoxicity()` flags if the response variable exceeds a limit in
#'  either direction as evidence of an effect.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param effect Numeric. Dictates at the value beyond which observations
#'  are flagged as toxic. This value can be further customized; see
#'  see `type` and `direction`.
#' @param type Character. Indicates if `effect` is `"relative"` to
#'  `reference group` or an `"absolute"` value. Defaults to relative.
#' @param direction Character. Indicates if an effect occurs `"below"` or
#'  `"above"`. Defaults to below.
#' @param reference_group Label used for reference group in `Conc` column.
#'  Defaults to 0.
#' @param target_group Optional. Limits the compairison to certain levels in
#'  `Conc`.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#'
#' @returns TRUE if the response variable exceeds a limit in either
#'  direction and FALSE otherwise. If `list_obj` is provided, returns this
#'  within a list as `list_obj$effect`.
#'
#' @export
#'
#' @examples
#' checktoxicity(
#'  dataset = toxresult,
#'  Conc = Conc,
#'  Response = RFU,
#'  effect = 0.5
#' )
#'
checktoxicity <- function(
  dataset,
  Conc,
  Response,
  effect,
  type = c("relative", "absolute"),
  direction = c("below", "above"),
  reference_group = "0",
  target_group = NULL,
  list_obj = NULL,
  quiet = FALSE
) {
  type <- match.arg(type)
  direction <- match.arg(direction)

  # establish threshold for both relative and absolute

  if (type == "relative") {
    response_threshold <- dataset %>%
      dplyr::filter({{ Conc }} == reference_group) %>%
      dplyr::summarise(
        threshold = mean({{ Response }}, na.rm = TRUE) * effect
      ) %>%
      dplyr::pull(.data$threshold)
  } else {
    response_threshold <- effect
  }

  .data <- NULL # to avoid error from NSE in pull

  #filter dataset if needed
  if (!is.null(target_group)) {
    summary_df <- dataset %>%
      dplyr::filter({{ Conc }}) ==
      target_group
  } else {
    summary_df <- dataset
  }

  response_values <- summary_df %>%
    dplyr::filter(!is.na({{ Response }})) %>%
    dplyr::pull({{ Response }})

  #if below

  if (direction == "below") {
    all_above <- all(response_values > response_threshold)
    if (all_above == TRUE) {
      statment <- ("Test effect does not exceed threshold")
      toxic_effect <- FALSE
    } else {
      statment <- ("Test effect exceeds threshold")
      toxic_effect <- TRUE
    }
  }

  # this does not work, all would need to be above, if ANY are below.

  if (direction == "above") {
    all_below <- all(response_values < response_threshold)
    if (all_below == TRUE) {
      statment <- ("Test effect does not exceed threshold")
      toxic_effect <- FALSE
    } else {
      statment <- ("Test effect exceeds threshold")
      toxic_effect <- TRUE
    }
  }

  if (!quiet) {
    print(statment)
  }

  # store results

  if (is.null(list_obj)) {
    return(toxic_effect)
  }

  if (is.list(list_obj)) {
    list_obj$effect <- toxic_effect
    return(list_obj)
  } else {
    stop("Provided list_obj must be a list.")
  }
}
