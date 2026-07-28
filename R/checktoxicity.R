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
#' @param target_group Optional. Limits the comparison to certain levels in
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

  check_dataset(dataset)
  check_column(dataset, rlang::enquo(Conc), "Conc")
  check_column(dataset, rlang::enquo(Response), "Response")
  check_number(effect, "effect")
  check_flag(quiet, "quiet")
  check_list_obj(list_obj)

  if (!is.null(target_group)) {
    check_group(dataset, rlang::enquo(Conc), target_group, "target_group")
  }

  # Only the relative threshold depends on the reference group, so an absent
  # label is only an error in that case.
  if (type == "relative") {
    check_group(
      dataset,
      rlang::enquo(Conc),
      reference_group,
      "reference_group"
    )
  }

  # Declared here only to satisfy R CMD check; .data is an rlang pronoun
  # resolved inside the dplyr pipeline below.
  .data <- NULL

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

  #filter dataset if needed
  if (!is.null(target_group)) {
    summary_df <- dataset %>%
      dplyr::filter({{ Conc }} %in% target_group)
  } else {
    summary_df <- dataset
  }

  response_values <- summary_df %>%
    dplyr::filter(!is.na({{ Response }})) %>%
    dplyr::pull({{ Response }})

  if (length(response_values) == 0) {
    toxdrc_abort(
      c(
        "No non-missing response values are available to test.",
        "i" = if (is.null(target_group)) {
          "Every value in the response column is NA."
        } else {
          "Check whether `target_group` selected any rows."
        }
      ),
      class = "no_response_values"
    )
  }

  if (is.na(response_threshold)) {
    toxdrc_abort(
      c(
        "The toxicity threshold could not be calculated.",
        "x" = if (type == "relative") {
          paste0(
            "The mean response of reference group \"", reference_group,
            "\" is NA."
          )
        } else {
          "`effect` is NA."
        },
        "i" = "Check that the reference group has non-missing responses."
      ),
      class = "undefined_threshold"
    )
  }

  #if below

  if (direction == "below") {
    all_above <- all(response_values > response_threshold)
    if (all_above == TRUE) {
      statement <- ("Test effect does not exceed threshold")
      toxic_effect <- FALSE
    } else {
      statement <- ("Test effect exceeds threshold")
      toxic_effect <- TRUE
    }
  }

  if (direction == "above") {
    all_below <- all(response_values < response_threshold)
    if (all_below == TRUE) {
      statement <- ("Test effect does not exceed threshold")
      toxic_effect <- FALSE
    } else {
      statement <- ("Test effect exceeds threshold")
      toxic_effect <- TRUE
    }
  }

  if (!quiet) {
    print(statement)
  }

  # store results

  if (is.null(list_obj)) {
    return(toxic_effect)
  }

  list_obj$effect <- toxic_effect
  list_obj
}
