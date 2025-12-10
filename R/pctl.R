#' Check for positive control effect
#'
#' @description
#' This function evaluates the difference between a two groups to determine if
#'  the difference between them exceeds a set amount. Commonly used to determine
#'  if a solvent introduces effects.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param reference_group Label used for the true control level.
#'  Defaults to "Control".
#' @param positive_group Label used for the positive control
#'  level. Defaults to 0.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param max_diff Numeric. Percent difference of the response in the
#'  `ref.label` and `pctl.label` groups beyond which tests are
#'  flagged. Defaults to 10.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.

#' @returns A modified `dataset` with an additional column, `Validity`. If
#'  `list_obj` is provided, returns this within a list as
#'  `list_obj$dataset`, along with statistics of the positive and reference
#'  group as `list_obj$pctlresults`.
#'
#' @export
#'
#' @examples
#' pctl(
#'  dataset = toxresult,
#'  Conc = Conc,
#'  Response = RFU,
#'  reference_group = "Control",
#'  positive_group = "0"
#')

pctl <- function(
  dataset,
  Conc,
  reference_group = "Control",
  positive_group = 0,
  Response,
  max_diff = 10,
  list_obj = NULL,
  quiet = FALSE
) {
  dataset <- dataset %>%
    dplyr::mutate(
      Validity = ""
    )

  # Check if both necessary groups exist
  if (
    !(reference_group %in% dplyr::pull(dataset, {{ Conc }})) ||
      !(positive_group %in% dplyr::pull(dataset, {{ Conc }}))
  ) {
    stop('Both reference and positive groups are required for check.')
  }

  # Calculate means
  pctl_resp <- mean(
    dplyr::pull(
      dataset %>% dplyr::filter({{ Conc }} == positive_group),
      {{ Response }}
    ),
    na.rm = TRUE
  )
  ref_resp <- mean(
    dplyr::pull(
      dataset %>% dplyr::filter({{ Conc }} == reference_group),
      {{ Response }}
    ),
    na.rm = TRUE
  )

  percent_diff <- abs((ref_resp - pctl_resp) / ref_resp) * 100

  # Prepare summary
  summary_df <- data.frame(
    p_ctl_mean = c(pctl_resp),
    ref_ctl_mean = c(ref_resp),
    percent_difference = c(percent_diff)
  )

  if (!quiet) {
    print(summary_df)
  }

  # Flag if percent difference is too high
  if (percent_diff > max_diff) {
    dataset$Validity <- "*"
  }

  # Output logic
  if (!is.null(list_obj)) {
    if (!is.list(list_obj)) {
      stop("Provided list_obj must be a list.")
    }
    list_obj$dataset <- dataset
    list_obj$pctlresults <- summary_df
    return(list_obj)
  }
  return(dataset)
}
